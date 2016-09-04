require_relative './de/initial_vector_creator.rb'
require_relative './de/mutated_vector_creator.rb'
require_relative './de/crossover_executor.rb'
require_relative './de/selection_executor.rb'

class DE
  DEFAULT_OPTION = {
    dimension: 2,
    number_of_vectors: 50,
    max_generation: 1000,
    max_evaluation: 100000,
    initial_value_min: -100,
    initial_value_max: 100,
    mutation_magnification_rate: 0.5,
    crossover_use_mutated_component_rate: 0.5
  }

  attr_reader :f, :vectors, :min_vector, :time, :generation, :evaluation_count
  attr_reader(*DEFAULT_OPTION.keys)

  def initialize(f = nil, option = {})
    @generation, @evaluation_count = 1, 0
    @f = f
    f_option = @f != nil ? @f.option : {}
    set_option(DEFAULT_OPTION.merge(f_option).merge(option))
  end

  def exec
    @time = Benchmark.realtime do
      set_initial_vectors

      loop do
        break if generation >= max_generation || evaluation_count >= max_evaluation
        exec_initialization_of_beginning_generation
        exec_mutation
        exec_crossover
        exec_selection
        exec_termination_of_ending_generation
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
    @vectors = (self.class)::InitialVectorCreator.new(
      dimension: dimension,
      min: initial_value_min,
      max: initial_value_max
    ).create(number_of_vectors)
  end

  def exec_initialization_of_beginning_generation
    # override this if there is need to do something at begininng of each generation
  end

  def exec_mutation
    @mutated_vectors = (self.class)::MutatedVectorCreator.new(@vectors, magnification_rate: mutation_magnification_rate).create
  end

  def exec_crossover
    @children_vectors = (self.class)::CrossoverExecutor.new(
      parent_vectors: @vectors,
      mutated_vectors: @mutated_vectors,
      use_mutated_component_rate: crossover_use_mutated_component_rate
    ).create_children
  end

  def exec_selection
    selection_executor = (self.class)::SelectionExecutor.new \
      parents: @vectors,
      children: @children_vectors,
      f: f,
      evaluation_rest: max_evaluation - @evaluation_count
    @vectors = selection_executor.create_selected_vectors
    @evaluation_count += selection_executor.evaluation_count
    @min_vector = @vectors.min { |a, b| a.calculated_value <=> b.calculated_value }

    selection_executor # use this returned value and extract properties in subclass if needed
  end

  def exec_termination_of_ending_generation
    # override this if there is need to do something at ending of each generation
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
