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
options = {
  f: f,
  dimension: 20,
  number_of_vectors: 50,
  max_generation: 200,
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
}

trial_num = 1 # Assume this is odd
jades = Array.new(trial_num) { JADE.new(options) }
sjades = Array.new(trial_num) { SJADE.new(options) }

jades.each(&:exec)
sjades.each(&:exec)

center_index = (trial_num - 1) / 2
median_jade = jades.sort { |j| j.min_vectors.last.calculated_value }[center_index]
median_sjade = sjades.sort { |j| j.min_vectors.last.calculated_value }[center_index]

jade_min = median_jade.min_vectors.map(&:calculated_value)
sjade_min = median_sjade.min_vectors.map(&:calculated_value)

p = DE::Plotter.new
p.add_min_value_transition('jade', jade_min)
p.add_min_value_transition('sjade', sjade_min)
# p.plot_min_value_transitions

jade_mean = median_jade.parameter_mean_history
jade_all = median_jade.parameter_all_history

sjade_mean = median_sjade.parameter_mean_history
sjade_all = median_sjade.parameter_all_history

p = DE::Plotter.new
p.add_parameter_transition('jade', jade_mean)
p.add_parameters_transition('jade all', jade_all)

# p.plot_parameter_transitions(plot_c: false)

p.plot_parameter_transitions_2d_animation

p = DE::Plotter.new
p.add_parameter_transition('jade', jade_mean)
p.add_parameter_transition('sjade', sjade_mean)
# p.plot_parameter_transitions(plot_c: false)
