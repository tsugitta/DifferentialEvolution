require_relative './utility.rb'
require_relative './benchmark_function.rb'
require_relative './de.rb'
require_relative './de/plotter.rb'
require_relative './jade.rb'
require_relative './shade.rb'
require_relative './djade.rb'

if %w(c console).include?(ARGV.first)
  binding.pry
  exit
end

f = BenchmarkFunction::F6.new
options = {
  f: f,
  dimension: 20,
  number_of_vectors: 50,
  max_generation: 300,
  max_evaluation: 100000,

  mutation_method: 'current-to-pbest/1',
  crossover_method: 'binomial',

  # used only when method is 'current-to-pbest/1'
  p_to_use_current_to_pbest_mutation: 0.1,
  archived_vectors_size: 50,

  # used as initial value for adaptive type
  mutation_magnification_rate: 0.5,
  crossover_use_mutated_component_rate: 0.5,

  # JADE, SHADE, DJADE options:
  normal_distribution_sigma: 0.1,
  cauchy_distribution_gamma: 0.1,

  # JADE, DJADE options:
  c_to_use_new_rate_mean_weight: 0.1,

  # SHADE options:
  memory_size: 5,

  # DJADE options:
  weight: 0.2
}

trial_num = 1 # Assume this is odd
jades = Array.new(trial_num) { JADE.new(options) }
djades = Array.new(trial_num) { DJADE.new(options) }

jades.each(&:exec)
djades.each(&:exec)

center_index = (trial_num - 1) / 2
median_jade = jades.sort { |j| j.min_vectors.last.calculated_value }[center_index]
median_djade = djades.sort { |j| j.min_vectors.last.calculated_value }[center_index]

jade_min = median_jade.min_vectors.map(&:calculated_value)
djade_min = median_djade.min_vectors.map(&:calculated_value)

p = DE::Plotter.new
p.add_min_value_transition('jade', jade_min)
p.add_min_value_transition('djade', djade_min)
p.plot_min_value_transitions

p = DE::Plotter.new
# p.add_parameters_transition('jade params', median_jade.parameter_all_history)
p.add_parameter_transition('jade success', median_jade.parameter_success_history)
p.add_parameter_transition('jade mean', median_jade.parameter_mean_history)
p.plot_parameter_transitions

p = DE::Plotter.new
# p.add_parameters_transition('djade params', median_djade.parameter_all_history)
p.add_parameter_transition('djade fail', median_djade.parameter_fail_history)
p.add_parameter_transition('djade success', median_djade.parameter_success_history)
p.add_parameter_transition('djade mean', median_djade.parameter_mean_history)
p.plot_parameter_transitions

# p = DE::Plotter.new
# p.add_parameters_transition('djade params', median_djade.parameter_all_history)
# p.add_parameter_transition('djade success', median_djade.parameter_success_history)
# p.add_parameter_transition('djade mean', median_djade.parameter_mean_history)
# p.plot_parameter_transitions()
