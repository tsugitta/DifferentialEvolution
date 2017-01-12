require_relative './jade.rb'
require_relative './oracle_simulator/oracle_simulatable.rb'

class SJADE < JADE
  SJADE_DEFAULT_OPTION = {
    ratio_to_regard_as_success: 0.3
  }

  attr_reader(*SJADE_DEFAULT_OPTION.keys)

  def initialize(option = {})
    option = SJADE_DEFAULT_OPTION.merge(option)

    super(option)
  end

  def update_parameters
    success_count = (@parameters.size * ratio_to_regard_as_success).floor
    success_parameters = @parameters.sort_by(&:calculated_value_diff).first(success_count)

    worst_parameter_in_success_parameters = success_parameters.last
    diff_sum = 0
    c_sum = 0
    f_sum = 0
    success_parameters.each do |p|
      diff = worst_parameter_in_success_parameters.calculated_value_diff - p.calculated_value_diff
      diff_sum += diff
      c_sum += diff * p.use_mutated_component_rate
      f_sum += diff * p.magnification_rate
    end

    c_mean = c_sum / diff_sum - 0.0
    f_mean = f_sum / diff_sum

    c = c_to_use_new_rate_mean_weight
    @parameter_means = Parameter.new \
      (1 - c) * @parameter_means.magnification_rate + c * f_mean,
      (1 - c) * @parameter_means.use_mutated_component_rate + c * c_mean
  end

  def parameter_information
    information = super
    information += ('\n' + "ratio to regard as success: #{ratio_to_regard_as_success}")
    information
  end
end
