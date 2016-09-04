require_relative './utility.rb'
require_relative './oracle_simulator/function.rb'
require_relative './oracle_simulator/success_checker.rb'
require_relative './de.rb'
require_relative './jade.rb'

oracle_function = OracleSimulator::Function::F2.new
success_checker = OracleSimulator::SuccessChecker::F1.new
de = JADE.new(
  dimension: 2,
  number_of_vectors: 50,
  max_generation: 50000,
  max_evaluation: 100000,
  initial_value_min: -100,
  initial_value_max: 100,
  initial_magnification_rate_mean: 0.5,
  initial_use_mutated_component_rate_mean: 0.5,
  normal_distribution_sigma: 0.1,
  cauchy_distribution_gamma: 0.1,
  p_to_use_current_to_pbest_mutation: 0.1,
  archived_vectors_size: 50,
  c_to_use_new_rate_mean_weight: 0.05
)
de.oracle_simulate(oracle_function, success_checker)
