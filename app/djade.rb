require_relative './jade.rb'
require_relative './oracle_simulator/oracle_simulatable.rb'

class DJADE < JADE
  DJADE_DEFAULT_OPTION = {
    weight: 0.1
  }

  attr_reader(*DJADE_DEFAULT_OPTION.keys)
  attr_reader :parameter_fail_history

  def initialize(option = {})
    option = DJADE_DEFAULT_OPTION.merge(option)

    super(option)

    @parameter_fail_history = []
  end

  def update_parameters
    success_parameters = @parameters.sort_by(&:calculated_value_diff).select { |p| p.calculated_value_diff < 0 }
    fail_parameters = @parameters.sort_by(&:calculated_value_diff).select { |p| p.calculated_value_diff >= 0 }

    worst_parameter_in_success_parameters = success_parameters.last
    diff_sum = 0
    c_sum = 0
    f_sum = 0
    f_square_sum = 0
    success_parameters.each do |p|
      diff = worst_parameter_in_success_parameters.calculated_value_diff - p.calculated_value_diff
      diff_sum += diff
      c_sum += diff * p.use_mutated_component_rate
      f_sum += diff * p.magnification_rate
      f_square_sum += diff * p.magnification_rate ** 2
    end

    unless diff_sum == 0
      c_mean = c_sum / diff_sum
      f_mean = f_square_sum / f_sum
      # f_mean = f_sum / diff_sum
    end

    best_parameter_in_fail_parameters = fail_parameters.first
    fail_diff_sum = 0
    fail_c_sum = 0
    fail_f_sum = 0
    fail_f_square_sum = 0
    fail_parameters.each do |p|
      diff = p.calculated_value_diff - best_parameter_in_fail_parameters.calculated_value_diff
      fail_diff_sum += diff
      fail_c_sum += diff * p.use_mutated_component_rate
      fail_f_sum += diff * p.magnification_rate
      fail_f_square_sum += diff * p.magnification_rate ** 2
    end

    unless fail_diff_sum == 0
      fail_c_mean = fail_c_sum / fail_diff_sum
      fail_f_mean = fail_f_square_sum / fail_f_sum
      # fail_f_mean = fail_f_sum / fail_diff_sum
      # f_mean = f_sum / diff_sum
    end

    if c_mean && fail_c_mean
      s_rate = success_parameters.size / @parameters.size
      res_c_mean = c_mean + (c_mean - fail_c_mean) * weight
      res_f_mean = f_mean + (f_mean - fail_f_mean) * weight
    elsif c_mean
      res_c_mean = c_mean
      res_f_mean = f_mean
    elsif fail_c_mean
      res_c_mean = @parameter_means.use_mutated_component_rate + (@parameter_means.use_mutated_component_rate - fail_c_mean) * weight
      res_f_mean = @parameter_means.magnification_rate + (@parameter_means.magnification_rate - fail_f_mean) * weight
    else
      res_c_mean = @parameter_means.use_mutated_component_rate
      res_f_mean = @parameter_means.magnification_rate
    end
    # res_c_mean = c_mean
    # res_f_mean = f_mean

    p = Parameter.new \
      magnification_rate: res_f_mean,
      use_mutated_component_rate: res_c_mean


    @parameter_success_history << Parameter.new(
      magnification_rate: f_mean,
      use_mutated_component_rate: c_mean
    )

    @parameter_fail_history << Parameter.new(
      magnification_rate: fail_f_mean,
      use_mutated_component_rate: fail_c_mean
    )

    c = c_to_use_new_rate_mean_weight
    @parameter_means = Parameter.new \
      magnification_rate: (1 - c) * @parameter_means.magnification_rate + c * res_f_mean,
      use_mutated_component_rate: (1 - c) * @parameter_means.use_mutated_component_rate + c * res_c_mean
  end

  def parameter_information
    information = super
    information += ('\n' + "weight: #{weight}")
    information
  end
end
