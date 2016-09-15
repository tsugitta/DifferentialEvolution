module OracleSimulator end
class OracleSimulator::SuccessChecker end

# Line: y = alpha * x + beta
class OracleSimulator::SuccessChecker::F2 < OracleSimulator::SuccessChecker
  include Math

  OPTION = {
    alpha: 0.1,
    beta: 200
  }

  def initialize(option = {})
    @option = OPTION.merge(option)
  end

  def succeeded?(oracle_parameter, parameter)
    rand < success_rate(oracle_parameter, parameter)
  end

  def label
    "Exponential(alpha: #{@option[:alpha]}, beta: #{@option[:beta]})"
  end


  def success_rate(p_a, p_b)
    @option[:alpha] * exp(-1 * @option[:beta] * distance_square(p_a, p_b))
  end

  private

  def distance(p_a, p_b)
    sqrt(distance_square(p_a, p_b))
  end

  def distance_square(p_a, p_b)
    square_sum = 0

    (p_a.class)::ATTRIBUTES.each do |attr|
      square_sum += (p_a.send(attr) - p_b.send(attr)) ** 2
    end

    square_sum
  end
end
