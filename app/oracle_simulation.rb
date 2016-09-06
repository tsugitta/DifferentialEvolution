require_relative './utility.rb'
require_relative './oracle_simulator/function.rb'
require_relative './oracle_simulator/success_checker.rb'
require_relative './de.rb'
require_relative './jade.rb'
require_relative './shade.rb'

oracle_f1 = OracleSimulator::Function::F1.new \
  alpha: -0.1,
  beta: 0.5
oracle_f2 = OracleSimulator::Function::F2.new \
  alpha: 0.3,
  omega: 20,
  beta: 0.3
oracle_f3 = OracleSimulator::Function::F3.new \
  initial_value: 0.5,
  step: 0.005

success_checker = OracleSimulator::SuccessChecker::F1.new

de = SHADE.new(
  number_of_vectors: 50,
  max_generation: 30000,
  p_to_use_current_to_pbest_mutation: 0.1,

  # JADE options:
  initial_magnification_rate_mean: 0.5,
  initial_use_mutated_component_rate_mean: 0.5,
  normal_distribution_sigma: 0.1,
  cauchy_distribution_gamma: 0.1,
  c_to_use_new_rate_mean_weight: 0.1,

  # SHADE options:
  memory_size: 3,
  initial_magnification_rate: 0.5,
  initial_use_mutated_component_rate: 0.5
)
de.oracle_simulate(oracle_f3, success_checker)
