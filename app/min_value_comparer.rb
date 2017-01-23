require_relative './utility.rb'
require_relative './benchmark_function.rb'
require_relative './de.rb'
require_relative './de/plotter.rb'
require_relative './jade.rb'
require_relative './shade.rb'
require_relative './rjade.rb'

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

    # JADE, SHADE, RJADE options:
    normal_distribution_sigma: 0.1,
    cauchy_distribution_gamma: 0.1,

    # JADE, RJADE options:
    c_to_use_new_rate_mean_weight: 0.1,

    # SHADE options:
    memory_size: 5,

    # RJADE options:
    weight: 0.2
  }

  trial_num = 15 # Assume this is odd
  center_index = (trial_num - 1) / 2
  p = DE::Plotter.new

  jades = Array.new(trial_num) { JADE.new(options) }
  jades.each(&:exec)
  median_jade = jades.sort { |j| j.min_vectors.last.calculated_value }[center_index]
  jade_min = median_jade.min_vectors.map(&:calculated_value)
  p.add_min_value_transition('jade', jade_min)

  0.step(1, 0.2) do |weight|
    weight = weight.round(1)
    weight_changed_options = options.merge(weight: weight)
    rjades = Array.new(trial_num) { RJADE.new(weight_changed_options) }
    rjades.each(&:exec)
    median_rjade = rjades.sort { |j| j.min_vectors.last.calculated_value }[center_index]
    rjade_min = median_rjade.min_vectors.map(&:calculated_value)
    p.add_min_value_transition("rjade #{weight}", rjade_min)
  end

  p.plot_min_value_transitions("#{f.label} min")
end
