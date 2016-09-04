module OracleSimulator end
class OracleSimulator::Function end

# Line: y = alpha * x + beta
class OracleSimulator::Function::F1 < OracleSimulator::Function
  OPTION = {
    alpha: 0.4,
    beta:  0.5
  }

  def calc(x)
    raise 'x must be in [0, 1]' unless x >= 0 && x <= 1
    OPTION[:alpha] * x + OPTION[:beta]
  end
end
