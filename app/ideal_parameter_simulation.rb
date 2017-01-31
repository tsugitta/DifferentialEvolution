require_relative './utility.rb'
require_relative './benchmark_function.rb'
require_relative './de.rb'
require_relative './de/plotter.rb'
require_relative './de/diff_of_all_parameters_plotter.rb'
require_relative './jade.rb'
require_relative './shade.rb'
require_relative './djade.rb'

if %w(c console).include?(ARGV.first)
  binding.pry
  exit
end

fs = [
  # BenchmarkFunction::F1.new,
  BenchmarkFunction::F2.new,
  BenchmarkFunction::F3.new,
  BenchmarkFunction::F4.new,
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

  pd_viewer_options_base = {
    mutation_method: 'current-to-pbest/1',
    crossover_method: 'binomial',
    p_to_use_current_to_pbest_mutation: 0.1,
    f: f
  }

  gen10_options = options.merge(max_generation: 2)
  jade10 = JADE.new(gen10_options)
  jade10.exec

  pd_viewer = DiffOfAllParametersPlotter.new(pd_viewer_options_base.merge(
    vectors: jade10.vectors,
    archived_vectors: jade10.archived_vectors,
    title: "JADE f: #{f.label} gen: 10"
  ))
  pd_viewer.exec

  gen100_options = options.merge(max_generation: 100)
  jade100 = JADE.new(gen100_options)
  jade100.exec

  pd_viewer = DiffOfAllParametersPlotter.new(pd_viewer_options_base.merge(
    vectors: jade100.vectors,
    archived_vectors: jade100.archived_vectors,
    title: "JADE f: #{f.label} gen: 100"
  ))
  pd_viewer.exec

  # gen200_options = options.merge(max_generation: 200)
  # jade200 = JADE.new(gen200_options)
  # jade200.exec
  # pd_viewer = DiffOfAllParametersPlotter.new(pd_viewer_options_base.merge(
  #   vectors: jade200.vectors,
  #   archived_vectors: jade200.archived_vectors,
  #   title: "JADE f: #{f.label} gen: 200"
  # ))
  # pd_viewer.exec

  gen300_options = options.merge(max_generation: 300)
  jade300 = JADE.new(gen300_options)
  jade300.exec

  pd_viewer = DiffOfAllParametersPlotter.new(pd_viewer_options_base.merge(
    vectors: jade300.vectors,
    archived_vectors: jade300.archived_vectors,
    title: "JADE f: #{f.label} gen: 300"
  ))
  pd_viewer.exec
end
