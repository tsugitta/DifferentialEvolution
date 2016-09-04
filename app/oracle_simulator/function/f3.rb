module OracleSimulator end
class OracleSimulator::Function end

# random walk: y_(n+1) = y_n + s * rand[-1 ,1]
class OracleSimulator::Function::F3 < OracleSimulator::Function
  OPTION = {
    initial_value: 0.5,
    step: 0.001
  }

  def initialize
    @last_calculated_value = OPTION[:initial_value]
  end

  def calc(x)
    calculated_value = @last_calculated_value + OPTION[:step] * [1, -1].sample

    if calculated_value > 0.9
      calculated_value = 2 * 0.9 - calculated_value
    elsif calculated_value < 0.1
      calculated_value = 2 * 0.1 - calculated_value
    end

    @last_calculated_value = calculated_value
    calculated_value
  end
end
