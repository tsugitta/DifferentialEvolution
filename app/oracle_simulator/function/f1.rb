module OracleSimulator end
class OracleSimulator::Function end

# Line: y = alpha * x + beta
class OracleSimulator::Function::F1 < OracleSimulator::Function
  OPTION = {
    alpha: -0.4,
    beta:  0.5
  }

  def initialize(option = {})
    @option = OPTION.merge(option)
  end

  def calc(x)
    raise 'x must be in [0, 1]' unless x >= 0 && x <= 1
    @option[:alpha] * x + @option[:beta]
  end
end
