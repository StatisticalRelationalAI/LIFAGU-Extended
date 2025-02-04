using Statistics

@isdefined(nanos_to_millis) || include(string(@__DIR__, "/../src/helper.jl"))

"""
	prepare_times(file::String)

Parse the times of the BLOG inference output, build averages and
write the results into a new `.csv` file.
"""
function prepare_times(file::String)
	averages = Dict()
	open(file, "r") do io
		readline(io) # Remove header
		for line in readlines(io)
			cols = split(line, ",")
			engine = cols[1]
			name = cols[2]
			if engine == "fove.LiftedVarElim" && contains(name, "-grt")
				continue
			end
			time = nanos_to_millis(parse(Float64, cols[12]))
			d = match(r"d=(\d+)-", name)[1]
			haskey(averages, engine) || (averages[engine] = Dict())
			haskey(averages[engine], d) || (averages[engine][d] = [])
			push!(averages[engine][d], time)
		end
	end
	open(replace(file, ".csv" => "-prepared.csv"), "a") do io
		write(io, "engine,d,min_time,max_time,mean_time,median_time,std\n")
		for (engine, d) in averages
			for (d, times) in d
				s = string(
					engine, ",",
					d, ",",
					minimum(times), ",",
					maximum(times), ",",
					mean(times), ",",
					median(times), ",",
					std(times), "\n"
				)
				write(io, s)
			end
		end
	end
end

"""
	prepare_errors(file::String)

Parse the Kulback-Leibler divergences for each instance and add a column `d`
for the domain size.
"""
function prepare_errors(file::String)
	data = []
	open(file, "r") do io
		head = split(readline(io), ",")
		push!(data, string(head[1], ",d,", join(head[2:end], ",")))
		for line in readlines(io)
			cols = split(line, ",")
			d = match(r"d=(\d+)-", cols[1])[1]
			push!(data, string(cols[1], ",", d, ",", join(cols[2:end], ",")))
		end
	end
	open(replace(file, ".csv" => "-prepared.csv"), "a") do io
		for line in data
			write(io, string(line, "\n"))
		end
	end
end

prepare_times(string(@__DIR__, "/_stats.csv"))
prepare_errors(string(@__DIR__, "/results.csv"))