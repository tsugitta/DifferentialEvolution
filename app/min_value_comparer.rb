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

fs = [
  BenchmarkFunction::F1.new,
  BenchmarkFunction::F2.new,
  BenchmarkFunction::F3.new,
  BenchmarkFunction::F4.new,
  BenchmarkFunction::F5.new,
  BenchmarkFunction::F6.new,
  BenchmarkFunction::F8.new
]

fs.each do |f|
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

  trial_num = 7 # Assume this is odd
  center_index = (trial_num - 1) / 2
  p = DE::Plotter.new
  p2 = DE::Plotter.new

  jades = Array.new(trial_num) { JADE.new(options) }
  jades.each(&:exec)
  median_jade = jades.sort { |j| j.min_vectors.last.calculated_value }[center_index]
  jade_min = median_jade.min_vectors.map(&:calculated_value)
  p.add_min_value_transition('jade', jade_min)
  # p.add_parameters_transition('jade params', median_jade.parameter_all_history)
  # p2.add_parameters_transition('jade', median_jade.parameter_all_history)
  p2.add_parameter_transition('jade', median_jade.parameter_mean_history)
  p2.plot_parameter_transitions(title: f.label, plot_c: false)
  p2.plot_parameter_transitions(title: f.label, plot_f: false)

  0.step(1, 0.2) do |weight|
    p3 = DE::Plotter.new
    weight = weight.round(1)
    next unless weight == 0.2 || weight == 0.6 || weight == 0.0
    weight_changed_options = options.merge(weight: weight)
    djades = Array.new(trial_num) { DJADE.new(weight_changed_options) }
    djades.each(&:exec)
    median_djade = djades.sort { |j| j.min_vectors.last.calculated_value }[center_index]
    djade_min = median_djade.min_vectors.map(&:calculated_value)
    p.add_min_value_transition("djade w: #{weight}", djade_min)
    p3.add_parameter_transition("mean", median_djade.parameter_mean_history)
    p3.add_parameter_transition("success mean", median_djade.parameter_success_history)
    p3.add_parameter_transition("fail mean", median_djade.parameter_fail_history)
    # p3.add_parameters_transition("djade w: #{weight}", median_djade.parameter_all_history)
    p3.plot_parameter_transitions(title: f.label + " djade w: #{weight}", plot_f: false)
    p3.plot_parameter_transitions(title: f.label + " djade w: #{weight}", plot_c: false)
  end

  p.plot_min_value_transitions("#{f.label}")
end
