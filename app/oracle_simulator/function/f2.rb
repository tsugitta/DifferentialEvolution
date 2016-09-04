module OracleSimulator end
class OracleSimulator::Function end

# sin: y = alpha * sin(omega * x) + beta
class OracleSimulator::Function::F2 < OracleSimulator::Function
  include Math

  OPTION = {
    alpha: -0.2,
    omega: 20,
    beta:  0.5
  }

  def initialize(option = {})
    @option = OPTION.merge(option)
  end

  def calc(x)
    raise 'x must be in [0, 1]' unless x >= 0 && x <= 1
    @option[:alpha] * sin(@option[:omega] * x) + @option[:beta]
  end
end
