require_relative './utility.rb'
require_relative './oracle_simulator/function.rb'
require_relative './oracle_simulator/success_checker.rb'
require_relative './de.rb'
require_relative './jade.rb'

oracle_function = OracleSimulator::Function::F3.new
success_checker = OracleSimulator::SuccessChecker::F1.new
de = JADE.new
de.oracle_simulate(oracle_function, success_checker)
