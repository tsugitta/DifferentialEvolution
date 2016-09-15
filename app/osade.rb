require_relative './de.rb'
require_relative './oracle_simulator/oracle_simulatable.rb'
require_relative './concerns/parameter_transition_plottable.rb'

class OSADE < DE
  include OracleSimulatable
  include ParameterTransitionPlottable

  OSADE_DEFAULT_OPTION = {
    osade_success_checker: nil,
    step_width: 0.01,
    normal_distribution_sigma: 0.1,
    cauchy_distribution_gamma: 0.1
  }

  attr_reader(*OSADE_DEFAULT_OPTION.keys)

  def initialize(option = {})
    raise 'success checker function must be passed.' unless option[:osade_success_checker] != nil
    option = OSADE_DEFAULT_OPTION.merge(option)

    super(option)

    @parameter_means = Parameter.new \
      mutation_magnification_rate,
      crossover_use_mutated_component_rate
    @parameter_mean_history = []
  end

  private

  def set_de_executors
    @initial_vector_creator_klass = DE::InitialVectorCreator
    @mutated_vector_creator_klass = DE::ParameterChangeableMutatedVectorCreator
    @crossover_executor_klass = DE::ParameterChangeableCrossoverExecutor
    @selection_executor_klass = DE::ParameterSaveableSelectionExecutor
  end

  def exec_initialization_before_beginning_generation
    save_parameter_to_history
  end

  def exec_initialization_of_beginning_generation
    @success_parameters = []
    @fail_parameters = []

    vectors.each do |vector|
      vector.parameter = create_parameter
    end
  end

  def save_parameter_to_history
    @parameter_mean_history << @parameter_means
  end

  def exec_selection
    selection_executor = super
    @success_parameters += selection_executor.success_parameters
    @fail_parameters += selection_executor.fail_parameters
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
    return if @success_parameters.empty? || @fail_parameters.empty?

    @parameter_means = get_oracle_parameter
  end

  def get_oracle_parameter
    min_magnification_rate = @success_parameters.map(&:magnification_rate).min
    max_magnification_rate = @success_parameters.map(&:magnification_rate).max
    min_use_mutated_component_rate = @success_parameters.map(&:use_mutated_component_rate).min
    max_use_mutated_component_rate = @success_parameters.map(&:use_mutated_component_rate).max

    oracle_parameter = nil
    producted_probability = 0

    min_magnification_rate.step(max_magnification_rate, step_width) do |f|
      min_use_mutated_component_rate.step(max_use_mutated_component_rate, step_width) do |c|
        oracle_parameter_candidate = Parameter.new(f, c)
        producted_probability_candidate = 1

        @success_parameters.each do |parameter|
          producted_probability_candidate *= osade_success_checker.success_rate(oracle_parameter_candidate, parameter)
        end

        @fail_parameters.each do |parameter|
          producted_probability_candidate *= (1 - osade_success_checker.success_rate(oracle_parameter_candidate, parameter))
        end

        if producted_probability_candidate > producted_probability
          oracle_parameter = oracle_parameter_candidate
          producted_probability = producted_probability_candidate
        end
      end
    end

    oracle_parameter
  end

  def parameter_information
    information = super
    information += ('\n' + "sigma for normal: #{normal_distribution_sigma}, gamma for cauchy: #{cauchy_distribution_gamma}, success checker: #{osade_success_checker.label}")
    information
  end

  def oracle_parameter_information
    super + [
      '\n' + "initial R: #{mutation_magnification_rate}, initial C: #{crossover_use_mutated_component_rate}",
      '\n' + "sigma for normal: #{normal_distribution_sigma}, gamma for cauchy: #{cauchy_distribution_gamma}, success checker: #{osade_success_checker.label}"
    ].join
  end

  def parameter_transition_plot_value
    x_plots = (1..@generation).to_a

    {
      magnification_rate: [x_plots, @parameter_mean_history.map { |p| p.magnification_rate }],
      use_mutated_component_rate: [x_plots, @parameter_mean_history.map { |p| p.use_mutated_component_rate}]
    }
  end
end
