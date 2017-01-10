require_relative './utility.rb'
require_relative './benchmark_function.rb'
require_relative './de.rb'
require_relative './jade.rb'
require_relative './shade.rb'

if %w(c console).include?ARGV.first
  binding.pry
  exit
end

f = BenchmarkFunction::F5.new(dim: 20)
de = JADE.new \
  f: f,
  dimension: 20,
  number_of_vectors: 50,
  max_generation: 5000,
  max_evaluation: 300000,
  initial_value_min: -100,
  initial_value_max: 100,

  mutation_method: 'current-to-pbest/1',
  crossover_method: 'binomial',

  # used only when method is 'current-to-pbest/1'
  p_to_use_current_to_pbest_mutation: 0.1,
  archived_vectors_size: 50,

  # used as initial value for adaptive type
  mutation_magnification_rate: 0.9,
  crossover_use_mutated_component_rate: 0.75,

  # JADE, SHADE options:
  normal_distribution_sigma: 0.1,
  cauchy_distribution_gamma: 0.1,

  # JADE options:
  c_to_use_new_rate_mean_weight: 0.1,

  # SHADE options:
  memory_size: 5

de.exec
