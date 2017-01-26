class DE
  DEFAULT_OPTION = {
    dimension: 2,
    number_of_vectors: 50,
    max_generation: 30000,
    max_evaluation: 300000,
    initial_value_min: -100,
    initial_value_max: 100,
    mutation_method: :rand_1,
    mutation_magnification_rate: 0.5,
    crossover_method: :binomial,
    crossover_use_mutated_component_rate: 0.5,
    p_to_use_current_to_pbest_mutation: 0.1,
    archived_vectors_size: 50,
  }

  attr_reader :f, :vectors, :min_vectors, :time, :generation, :evaluation_count
  attr_reader(*DEFAULT_OPTION.keys)

  def initialize(option = {})
    @generation, @evaluation_count = 1, 0
    @f = option[:f]
    f_option = @f != nil ? @f.option : {}
    set_option(DEFAULT_OPTION.merge(f_option).merge(option))

    @archived_vectors = [] if use_archive?
    set_de_executors
  end

  def exec
    @time = Benchmark.realtime do
      set_initial_vectors
      @min_vectors = []

      loop do
        exec_initialization_before_beginning_generation
        output_current_generation
        break if generation >= max_generation || evaluation_count >= max_evaluation
        exec_initialization_of_beginning_generation
        exec_mutation
        exec_crossover
        exec_selection
        exec_termination_of_ending_generation
        @generation += 1
      end
    end

    exec_termination_of_ending_calculation
  end

  private

  def set_option(option)
    option.each do |k, v|
      eval "@#{k} = v"
    end
  end

  def set_de_executors
    @initial_vector_creator_klass = DE::InitialVectorCreator
    @mutated_vector_creator_klass = DE::MutatedVectorCreator
    @crossover_executor_klass = DE::CrossoverExecutor
    @selection_executor_klass = DE::SelectionExecutor
  end

  def set_initial_vectors
    @vectors = @initial_vector_creator_klass.new(
      dimension: dimension,
      min: initial_value_min,
      max: initial_value_max
    ).create(number_of_vectors)
  end

  def output_current_generation
    print "\rgeneration: #{@generation}/#{max_generation}"
    print "\rdone. printing the result..               \n" if @generation >= max_generation
  end

  def exec_initialization_before_beginning_generation
    # override this if there is need to do something before beginning of each generation
  end

  def exec_initialization_of_beginning_generation
    @parameters = Array.new(vectors.count) { create_parameter }
  end

  def exec_mutation
    mutated_vector_creator = @mutated_vector_creator_klass.new \
      @vectors,
      parameters: @parameters,
      mutation_method: mutation_method,
      p: p_to_use_current_to_pbest_mutation,
      f: f,
      archived_vectors: @archived_vectors

    @mutated_vectors = mutated_vector_creator.create
    @evaluation_count += mutated_vector_creator.evaluation_count
  end

  def exec_crossover
    @children_vectors = @crossover_executor_klass.new(
      parent_vectors: @vectors,
      mutated_vectors: @mutated_vectors,
      parameters: @parameters,
      crossover_method: crossover_method
    ).create_children
  end

  def exec_selection
    selection_executor = @selection_executor_klass.new \
      parents: @vectors,
      children: @children_vectors,
      parameters: @parameters,
      f: f,
      evaluation_rest: max_evaluation - @evaluation_count
    @vectors = selection_executor.create_selected_vectors
    @evaluation_count += selection_executor.evaluation_count
    @min_vectors << @vectors.min { |a, b| a.calculated_value <=> b.calculated_value }

    update_archives_with(selection_executor.archived_vectors) if use_archive?

    selection_executor # use this returned value and extract properties in subclass if needed
  end

  def exec_termination_of_ending_generation
    # override this if there is need to do something at ending of each generation
  end

  def exec_termination_of_ending_calculation
    log_result
  end

  def create_parameter
    Parameter.new \
      magnification_rate: mutation_magnification_rate,
      use_mutated_component_rate: crossover_use_mutated_component_rate
  end

  def use_archive?
    DE::MutatedVectorCreator::USE_ARCHIVE_METHODS.include?(mutation_method)
  end

  def update_archives_with(new_archives)
    new_archives.each do |new_vector|
      if @archived_vectors.size >= archived_vectors_size
        @archived_vectors[rand(archived_vectors_size)] = new_vector
      else
        @archived_vectors << new_vector
      end
    end
  end

  def parameter_information
    information = [
      "#{self.class}, f: #{@f.label}, D: #{dimension}, N: #{number_of_vectors}, generation: #{@generation}, evaluation: #{@evaluation_count}",
      '\n' + "mutation: #{mutation_method}, crossover : #{@crossover_method}, C: #{crossover_use_mutated_component_rate}, R: #{mutation_magnification_rate}"
    ]
    information << ('\n' + "p for pbest: #{p_to_use_current_to_pbest_mutation}, archive size: #{archived_vectors_size}") if use_archive?
    information.join
  end

  def log_result
    puts <<~EOS
    #{parameter_information.gsub(/(, )|\\n/, "\n")}
    min: #{@min_vectors.last.calculated_value}
    vector: #{@min_vectors.last}
    time: #{time}s
    EOS
  end
end

require_relative './de/initial_vector_creator.rb'
require_relative './de/mutated_vector_creator.rb'
require_relative './de/crossover_executor.rb'
require_relative './de/selection_executor.rb'
