require_relative './de/basic.rb'

class DE
  DEFAULT_OPTION = {
    dimension: 2,
    number_of_vectors: 100,
    max_generation: 1000,
    initial_value_min: -100,
    initial_value_max: 100,
    mutation_magnification_rate: 0.5,
    crossover_use_mutated_component_rate: 0.5
  }

  attr_reader :f, :vectors
  attr_reader *DEFAULT_OPTION.keys

  def initialize(f, option = {})
    if f == nil || !f.is_a?(Benchmark)
      raise 'DE initialize must be passed the benchmark func as the first argument.'
    end

    @f = f
    set_option(DEFAULT_OPTION.merge(f.option).merge(option))
  end

  def exec
    raise 'DE#execute must be overridden.'
  end

  private

  def set_option(option)
    option.each do |k, v|
      eval "@#{k} = v"
    end
  end

  def set_initial_vectors
    @vectors = DE::InitialVectorCreator.create \
      length: number_of_vectors,
      dimension: dimension,
      min: initial_value_min,
      max: initial_value_max
  end

  def exec_mutation
    @mutated_vectors = DE::MutatedVectorCreator
      .create_from(@vectors, magnification_rate: mutation_magnification_rate)
  end

  def exec_crossover
    @children_vectors = DE::CrossoverExecutor.create_children \
      parent_vectors: @vectors,
      mutated_vectors: @mutated_vectors,
      use_mutated_component_rate: crossover_use_mutated_component_rate
  end
end
