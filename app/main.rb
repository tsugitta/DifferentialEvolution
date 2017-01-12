require_relative './utility.rb'
require_relative './benchmark_function.rb'
require_relative './de.rb'
require_relative './de/plotter.rb'
require_relative './jade.rb'
require_relative './shade.rb'
require_relative './sjade.rb'

if %w(c console).include?(ARGV.first)
  binding.pry
  exit
end

f = BenchmarkFunction::F1.new
de = SJADE.new \
  f: f,
  dimension: 20,
  number_of_vectors: 50,
  max_generation: 1000,
  max_evaluation: 300000,

  mutation_method: 'current-to-pbest/1',
  crossover_method: 'binomial',

  # used only when method is 'current-to-pbest/1'
  p_to_use_current_to_pbest_mutation: 0.1,
  archived_vectors_size: 50,

  # used as initial value for adaptive type
  mutation_magnification_rate: 0.9,
  crossover_use_mutated_component_rate: 0.1,

  # JADE, SHADE, SJADE options:
  normal_distribution_sigma: 0.1,
  cauchy_distribution_gamma: 0.1,

  # JADE, SJADE options:
  c_to_use_new_rate_mean_weight: 0.1,

  # SHADE options:
  memory_size: 5,

  # SJADE options:
  ratio_to_regard_as_success: 0.5

de.exec

min = de.min_vectors.map { |v| v.calculated_value }
p = DE::Plotter.new
p.add_min_value_transition('jade', min)
p.plot_min_value_transition

m = de.parameter_mean_history
al = de.parameter_all_history

p.add_parameter_transition('jade', al, m)
# p.plot_parameter_transition(plot_only_mean: false, plot_f: false)
p.plot_parameter_transition_2d_animation
