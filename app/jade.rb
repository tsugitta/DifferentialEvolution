require_relative './de.rb'
require_relative './oracle_simulator/oracle_simulatable.rb'
require_relative './concerns/parameter_transition_plottable.rb'

class JADE < DE
  include OracleSimulatable
  include ParameterTransitionPlottable

  JADE_DEFAULT_OPTION = {
    normal_distribution_sigma: 0.1,
    cauchy_distribution_gamma: 0.1,
    c_to_use_new_rate_mean_weight: 0.1
  }

  attr_reader(*JADE_DEFAULT_OPTION.keys)

  def initialize(option = {})
    option = JADE_DEFAULT_OPTION.merge(option)

    super(option)

    @parameter_means = Parameter.new \
      mutation_magnification_rate,
      crossover_use_mutated_component_rate
    @parameter_mean_history = []
  end

  private

  def exec_initialization_before_beginning_generation
    save_parameter_to_history
  end

  def save_parameter_to_history
    @parameter_mean_history << @parameter_means
  end

  def exec_selection
    selection_executor = super
    @parameters = selection_executor.value_assigned_parameters
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
    success_parameters = @parameters.select do |p|
      p.calculated_value_diff < 0
    end

    return if success_parameters.empty?

    c = c_to_use_new_rate_mean_weight
    @parameter_means = Parameter.new \
      (1 - c) * @parameter_means.magnification_rate + c * MathCalculator.lehmer_mean(success_parameters.map(&:magnification_rate)),
      (1 - c) * @parameter_means.use_mutated_component_rate + c * MathCalculator.arithmetic_mean(success_parameters.map(&:use_mutated_component_rate))
  end

  def parameter_information
    information = super
    information += ('\n' + "sigma for normal: #{normal_distribution_sigma}, gamma for cauchy: #{cauchy_distribution_gamma}, c to use new parameter: #{c_to_use_new_rate_mean_weight}")
    information
  end

  def oracle_parameter_information
    super + [
      '\n' + "initial R: #{mutation_magnification_rate}, initial C: #{crossover_use_mutated_component_rate}",
      '\n' + "sigma for normal: #{normal_distribution_sigma}, gamma for cauchy: #{cauchy_distribution_gamma}, c to use new mean: #{c_to_use_new_rate_mean_weight}"
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
