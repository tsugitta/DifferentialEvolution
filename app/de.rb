require_relative './de/initial_vector_creator.rb'
require_relative './de/mutated_vector_creator.rb'
require_relative './de/crossover_executor.rb'
require_relative './de/selection_executor.rb'

class DE
  DEFAULT_OPTION = {
    dimension: 2,
    number_of_vectors: 105,
    max_generation: 1000,
    max_evaluation: 100000,
    initial_value_min: -100,
    initial_value_max: 100,
    mutation_magnification_rate: 0.5,
    crossover_use_mutated_component_rate: 0.5
  }

  attr_reader :f, :vectors, :min_vector, :time, :generation, :evaluation_count
  attr_reader *DEFAULT_OPTION.keys

  def initialize(f, option = {})
    unless f.is_a?(BenchmarkFunction)
      raise 'DE initialize must be passed the benchmark func as the first argument.'
    end

    @generation, @evaluation_count = 1, 0
    @f = f
    set_option(DEFAULT_OPTION.merge(f.option).merge(option))
  end

  def exec
    @time = Benchmark.realtime do
      set_initial_vectors

      loop do
        break if generation >= max_generation || evaluation_count >= max_evaluation
        exec_mutation
        exec_crossover
        exec_selection
        @generation += 1
      end
    end

    log_result
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

  def exec_selection
    selection_executor = DE::SelectionExecutor.new \
      parents: @vectors,
      children: @children_vectors,
      f: f,
      evaluation_rest: max_evaluation - @evaluation_count
    @vectors = selection_executor.create_selected_vectors
    @evaluation_count += selection_executor.evaluation_count
    @min_vector = @vectors.min { |a, b| a.calculated_value <=> b.calculated_value }
  end

  def log_result
    puts <<~EOS
      dimension: #{dimension}
      number_of_vectors: #{number_of_vectors}
      generation: #{generation}
      evaluation: #{evaluation_count}
      function: #{f.class}
      mutation_magnification_rate: #{mutation_magnification_rate}
      crossover_use_mutated_component_rate: #{crossover_use_mutated_component_rate}

      min: #{min_vector.calculated_value}
      vector: #{min_vector}
      time: #{time}s
    EOS
  end
end
