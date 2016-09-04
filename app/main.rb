require_relative './utility.rb'
require_relative './benchmark_function.rb'
require_relative './de.rb'
require_relative './jade.rb'

f = BenchmarkFunction::F1.new
de = JADE.new \
  f: f,
  dimension: 2,
  number_of_vectors: 10,
  max_generation: 30000,
  max_evaluation: 300000,
  initial_value_min: -100,
  initial_value_max: 100,
  mutation_magnification_rate: 0.5,
  crossover_use_mutated_component_rate: 0.5,
  initial_magnification_rate_mean: 0.5,
  initial_use_mutated_component_rate_mean: 0.5,
  normal_distribution_sigma: 0.1,
  cauchy_distribution_gamma: 0.1,
  p_to_use_current_to_pbest_mutation: 0.1,
  archived_vectors_size: 50,
  c_to_use_new_rate_mean_weight: 0.001

de.exec
