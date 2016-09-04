module OracleSimulator end
class OracleSimulator::Function end

# sin: y = alpha * sin(omega * x) + beta
class OracleSimulator::Function::F2 < OracleSimulator::Function
  include Math

  OPTION = {
    alpha: -0.4,
    omega: 10,
    beta:  0.5
  }

  def calc(x)
    raise 'x must be in [0, 1]' unless x >= 0 && x <= 1
    OPTION[:alpha] * sin(OPTION[:omega] * x) + OPTION[:beta]
  end
end
