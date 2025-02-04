# LIFAGU-Extended

This repository contains the source code to reproduce the experiments in the
paper "Lifting Factor Graphs with Some Unknown Factors for New Individuals"
by Malte Luttermann, Ralf Möller, and Marcel Gehrke (IJAR 2025).

The code features the LIFAGU algorithm that has initially been presented in the
paper "Lifting Factor Graphs with Some Unknown Factors" by Malte Luttermann,
Ralf Möller, and Marcel Gehrke (ECSQARU 2023).
The initial source code of LIFAGU can be found [here](https://github.com/StatisticalRelationalAI/LIFAGU/tree/master).
The code in this repository slightly adapts the experimental setup, however,
the LIFAGU algorithm itself remains unchanged.

Our implementation uses the [Julia programming language](https://julialang.org).

## Computing Infrastructure and Required Software Packages

All experiments were conducted using Julia version 1.11.2 together with the following packages:
- BayesNets v3.4.1
- BenchmarkTools v1.6.0
- Combinatorics v1.0.2
- Graphs v1.9.0
- Multisets v0.4.5

Moreover, we use openjdk version 11.0.20 to run the (lifted) inference
algorithms, which are integrated via
`instances/ljt-v1.0-jar-with-dependencies.jar`.

## Instance Generation

Run `julia instance_generator.jl` in the directory `src/` to generate all input
instances for evaluation.
The generated instances are written to the directory `instances/` in binary format.

## Running the Experiments

After generating the instances, the experiments can be started by executing
`julia run_eval.jl` in the directory `src/`.
All results are written to the directory `results/`.
To obtain the plots, first run `julia prepare_plot.jl` in the directory `results/`
to combine the run times into averages and afterwards run the R script `plot.r`,
which creates `.tex` files (also in the directory `results/`) containing the
plots in TikZ.