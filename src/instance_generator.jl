using Random, StatsBase

@isdefined(FactorGraph)  || include(string(@__DIR__, "/factor_graph.jl"))
@isdefined(add_noise!)   || include(string(@__DIR__, "/helper.jl"))
@isdefined(Query)        || include(string(@__DIR__, "/queries.jl"))
@isdefined(save_to_file) || include(string(@__DIR__, "/helper.jl"))

function run_generation(
	output_dir=string(@__DIR__, "/../instances/input/"),
	seed::Int=123
)
	Random.seed!(seed)
	dom_sizes = [2, 4, 8, 16, 32, 64, 128, 256]

	for dom_size in dom_sizes
		# There are 3-5 cohorts, the first is very probable, the remaining
		# probabilities are uniformly distributed
		nc = rand(min(3, dom_size):5)
		for p in [0.2, 0.3, 0.5, 0.7, 0.9]
			p_str = replace(string(p), "." => "")
			weights = ProbabilityWeights([p, fill((1-p)/(nc-1), nc-1)...])
			fg, queries = gen_employee(dom_size)
			for f in filter(f -> contains(name(f), "com"), factors(fg))
				epsilon = sample(weights) / 10
				add_noise!(f.potentials, rand([-1,1]) * epsilon)
			end
			save_to_file((fg, queries), string(output_dir, "employee-d=$dom_size-p=$p_str.ser"))
		end
	end

	for dom_size in dom_sizes
		# There are 3-5 cohorts, the first is very probable, the remaining
		# probabilities are uniformly distributed
		nc = rand(min(3, dom_size):5)
		for p in [0.2, 0.3, 0.5, 0.7, 0.9]
			p_str = replace(string(p), "." => "")
			weights = ProbabilityWeights([p, fill((1-p)/(nc-1), nc-1)...])
			fg, queries = gen_epid(dom_size)
			for f in filter(f -> contains(name(f), "f2_"), factors(fg))
				epsilon = sample(weights) / 10
				add_noise!(f.potentials, rand([-1,1]) * epsilon)
			end
			save_to_file((fg, queries), string(output_dir, "epid-d=$dom_size-p=$p_str.ser"))
		end
	end
end

"""
	gen_randpots(ds::Array, seed::Int=123)::Vector{Tuple{Vector, Float64}}

Generate random potentials for a given array of ranges.
"""
function gen_randpots(rs::Array, seed::Int=123)::Vector{Tuple{Vector, Float64}}
	Random.seed!(seed)
	length(rs) > 5 && @warn("Generating at least 2^$(length(rs)) potentials!")

	potentials = []
	for conf in Iterators.product(rs...)
		push!(potentials, ([conf...], rand([0.5,1,1,1.5])))
	end

	return potentials
end

"""
	gen_employee(dom_size::Int, seed::Int=123)

Generate the employee example with the given domain size for employees.
"""
function gen_employee(
	dom_size::Int,
	seed::Int=123
)::Tuple{FactorGraph, Vector{Query}}
	Random.seed!(seed)
	fg = FactorGraph()

	rev = DiscreteRV("Rev")
	add_rv!(fg, rev)

	# All random variables are Boolean
	r = [true, false]
	p1 = [([true], 1), ([false], 1)]
	p2 = gen_randpots([r, r], 1)
	p3 = gen_randpots([r, r, r], 2)
	for i in 1:dom_size
		com = DiscreteRV("Com.$i")
		sal = DiscreteRV("Sal.$i")
		add_rv!(fg, com)
		add_rv!(fg, sal)

		f_com = DiscreteFactor("f_com$i", [com], p1)
		add_factor!(fg, f_com)
		add_edge!(fg, com, f_com)

		f_rev = DiscreteFactor("f_rev$i", [com, rev], p2)
		add_factor!(fg, f_rev)
		add_edge!(fg, com, f_rev)
		add_edge!(fg, rev, f_rev)

		f_sal = DiscreteFactor("f_sal$i", [com, rev, sal], p3)
		add_factor!(fg, f_sal)
		add_edge!(fg, com, f_sal)
		add_edge!(fg, rev, f_sal)
		add_edge!(fg, sal, f_sal)
	end

	queries = [Query("Rev"), Query("Com.1"), Query("Sal.1")]

	return fg, queries
end

"""
	gen_epid(
		dom_size::Int,
		seed::Int=123
	)::Tuple{FactorGraph, Vector{Query}}

Generate the epid example with the given domain size for people.
"""
function gen_epid(
	dom_size::Int,
	seed::Int=123
)::Tuple{FactorGraph, Vector{Query}}
	Random.seed!(seed)
	fg = FactorGraph()

	epid = DiscreteRV("Epid")
	f0 = DiscreteFactor("f0", [epid], [([true], 1), ([false], 1)])
	add_rv!(fg, epid)
	add_factor!(fg, f0)
	add_edge!(fg, epid, f0)

	# All random variables are Boolean
	r = [true, false]
	p1 = gen_randpots([r, r, r], 0)
	p2 = gen_randpots([r, r], 0)
	for i in 1:dom_size
		travel = DiscreteRV("Travel.$i")
		sick = DiscreteRV("Sick.$i")
		add_rv!(fg, travel)
		add_rv!(fg, sick)
		f1 = DiscreteFactor("f$i", [travel, sick, epid], p1)
		add_factor!(fg, f1)
		add_edge!(fg, travel, f1)
		add_edge!(fg, sick, f1)
		add_edge!(fg, epid, f1)
		treat = DiscreteRV("Treat.$i")
		add_rv!(fg, treat)
		f2 = DiscreteFactor("f2_$i", [treat, sick], p2)
		add_factor!(fg, f2)
		add_edge!(fg, treat, f2)
		add_edge!(fg, sick, f2)
	end

	queries = [Query("Epid"), Query("Travel.1"), Query("Sick.1"), Query("Treat.1")]

	return fg, queries
end

run_generation()
