require_relative './de.rb'
require_relative './oracle_simulator/oracle_simulatable.rb'
require_relative './concerns/parameter_transition_plottable.rb'

class SHADE < DE
  include OracleSimulatable
  include ParameterTransitionPlottable

  SHADE_DEFAULT_OPTION = {
    memory_size: 10,
    normal_distribution_sigma: 0.1,
    cauchy_distribution_gamma: 0.1
  }

  attr_reader(*SHADE_DEFAULT_OPTION.keys)

  def initialize(option = {})
    option = SHADE_DEFAULT_OPTION.merge(option)

    super(option)

    initialize_memory
  end

  private

  def initialize_memory
    @magnification_rate_memory = Array.new(memory_size, mutation_magnification_rate)
    @use_mutated_component_rate_memory = Array.new(memory_size, crossover_use_mutated_component_rate)

    @parameter_memory_history = {
      magnification_rate: Array.new(memory_size) { [] },
      use_mutated_component_rate: Array.new(memory_size) { [] }
    }
  end

  def set_de_executors
    @initial_vector_creator_klass = DE::InitialVectorCreator
    @mutated_vector_creator_klass = DE::ParameterChangeableMutatedVectorCreator
    @crossover_executor_klass = DE::ParameterChangeableCrossoverExecutor
    @selection_executor_klass = DE::SelectionExecutor
  end

  def exec_initialization_before_beginning_generation
    save_parameter_to_history
  end

  def save_parameter_to_history
    memory_size.times do |i|
      @parameter_memory_history[:magnification_rate][i] << @magnification_rate_memory[i]
      @parameter_memory_history[:use_mutated_component_rate][i] << @use_mutated_component_rate_memory[i]
    end
  end

  def exec_selection
    selection_executor = super
    @parameters = selection_executor.value_assigned_parameters
  end

  def exec_termination_of_ending_generation
    update_parameters
  end

  def create_parameter
    memory_index = rand(memory_size)

    Parameter.new \
      Random.rand_following_normal_from_0_to_1(
        @magnification_rate_memory[memory_index],
        normal_distribution_sigma
      ),
      Random.rand_following_cauchy_from_0_to_1(
        @use_mutated_component_rate_memory[memory_index],
        cauchy_distribution_gamma
      )
  end

  def update_parameters
    success_parameters = @parameters.select do |p|
      p.calculated_value_diff < 0
    end

    return if success_parameters.empty?

    memory_index = @generation % memory_size
    @magnification_rate_memory[memory_index] = MathCalculator.lehmer_mean(success_parameters.map(&:magnification_rate))
    @use_mutated_component_rate_memory[memory_index] = MathCalculator.lehmer_mean(success_parameters.map(&:use_mutated_component_rate))
  end

  def parameter_information
    information = super
    information += ('\n' + "sigma for normal: #{normal_distribution_sigma}, gamma for cauchy: #{cauchy_distribution_gamma}, memory size: #{memory_size}")
    information
  end

  def oracle_parameter_information
    super + [
      '\n' + "initial R: #{mutation_magnification_rate}, initial C: #{crossover_use_mutated_component_rate}",
      '\n' + "sigma for normal: #{normal_distribution_sigma}, gamma for cauchy: #{cauchy_distribution_gamma}, memory size: #{memory_size}"
    ].join
  end

  def parameter_transition_plot_value
    x_plots = (1..@generation).to_a * memory_size

    {
      magnification_rate: [x_plots, @parameter_memory_history[:magnification_rate].flatten],
      use_mutated_component_rate: [x_plots, @parameter_memory_history[:use_mutated_component_rate].flatten]
    }
  end
end
