module OracleSimulator end
class OracleSimulator::SuccessChecker end

# Line: y = alpha * x + beta
class OracleSimulator::SuccessChecker::F1 < OracleSimulator::SuccessChecker
  include Math

  OPTION = {
    alpha: 1,
    beta:  0.1
  }

  def initialize(option = {})
    @option = OPTION.merge(option)
  end

  def succeeded?(oracle_parameter, parameter)
    rand < success_rate(oracle_parameter, parameter)
  end

  def label
    "Line(alpha: #{@option[:alpha]}, beta: #{@option[:beta]})"
  end

  private

  def distance(p_a, p_b)
    square_sum = 0

    (p_a.class)::ATTRIBUTES.each do |attr|
      square_sum += (p_a.send(attr) - p_b.send(attr)) ** 2
    end

    sqrt(square_sum)
  end

  def success_rate(p_a, p_b)
    [
      -1 * @option[:alpha] * distance(p_a, p_b) + @option[:beta],
      0
    ].max
  end
end
