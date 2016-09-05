require_relative './de.rb'
require_relative './oracle_simulator/oracle_simulatable.rb'
require_relative './concerns/parameter_transition_plottable.rb'

class JADE < DE
  include OracleSimulatable
  include ParameterTransitionPlottable

  JADE_DEFAULT_OPTION = {
    initial_magnification_rate_mean: 0.5,
    initial_use_mutated_component_rate_mean: 0.5,
    normal_distribution_sigma: 0.1,
    cauchy_distribution_gamma: 0.1,
    c_to_use_new_rate_mean_weight: 0.1
  }

  attr_reader(*JADE_DEFAULT_OPTION.keys)

  def initialize(option = {})
    option = JADE_DEFAULT_OPTION.merge(option)

    super(option)

    @parameter_means = Parameter.new \
      initial_magnification_rate_mean,
      initial_use_mutated_component_rate_mean
    @parameter_mean_history = []
  end

  private

  def set_de_executors
    @initial_vector_creator_klass = DE::InitialVectorCreator
    @mutated_vector_creator_klass = DE::ParameterChangeableMutatedVectorCreator
    @crossover_executor_klass = DE::ParameterChangeableCrossoverExecutor
    @selection_executor_klass = DE::ParameterSaveableSelectionExecutor
  end

  def exec_initialization_of_beginning_generation
    @parameter_mean_history << @parameter_means
    @success_parameters = []

    vectors.each do |vector|
      vector.parameter = create_parameter
    end
  end

  def exec_selection
    selection_executor = super
    @success_parameters += selection_executor.success_parameters
  end

  def exec_termination_of_ending_generation
    update_parameters
  end

  def create_parameter
    Parameter.new \
      Random.rand_following_normal_from_0_to_1(
        @parameter_means.magnification_rate,
        normal_distribution_sigma
      ),
      Random.rand_following_cauchy_from_0_to_1(
        @parameter_means.use_mutated_component_rate,
        cauchy_distribution_gamma
      )
  end

  def update_parameters
    return if @success_parameters.empty?

    c = c_to_use_new_rate_mean_weight
    @parameter_means = Parameter.new \
      (1 - c) * @parameter_means.magnification_rate + c * MathCalculator.lehmer_mean(@success_parameters.map(&:magnification_rate)),
      (1 - c) * @parameter_means.use_mutated_component_rate + c * MathCalculator.arithmetic_mean(@success_parameters.map(&:use_mutated_component_rate))
  end

  def oracle_parameter_information
    super + ('\n' + "sigma for normal: #{normal_distribution_sigma}, gamma for cauchy: #{cauchy_distribution_gamma}, c to use new mean: #{c_to_use_new_rate_mean_weight}")
  end
end
