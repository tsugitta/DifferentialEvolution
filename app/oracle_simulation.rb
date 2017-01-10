require_relative './utility.rb'
require_relative './oracle_simulator/function.rb'
require_relative './oracle_simulator/success_checker.rb'
require_relative './de.rb'
require_relative './jade.rb'
require_relative './shade.rb'
require_relative './osade.rb'

if %w(c console).include?ARGV.first
  binding.pry
  exit
end

oracle_f1 = OracleSimulator::Function::F1.new \
  alpha: -0.1,
  beta: 0.5
oracle_f2 = OracleSimulator::Function::F2.new \
  alpha: 0.3,
  omega: 20,
  beta: 0.5
oracle_f3 = OracleSimulator::Function::F3.new \
  initial_value: 0.5,
  step: 0.005

success_checker_f1 = OracleSimulator::SuccessChecker::F1.new \
  alpha: 1,
  beta: 0.1

success_checker_f2 = OracleSimulator::SuccessChecker::F2.new \
  alpha: 0.1,
  beta: 200

de = OSADE.new(
  number_of_vectors: 50,
  max_generation: 4000,
  p_to_use_current_to_pbest_mutation: 0.1,
  mutation_magnification_rate: 0.5,
  crossover_use_mutated_component_rate: 0.5,

  # JADE, SHADE options:
  normal_distribution_sigma: 0.1,
  cauchy_distribution_gamma: 0.1,

  # JADE options:
  c_to_use_new_rate_mean_weight: 0.1,

  # SHADE options:
  memory_size: 5,

  # OBADE options:
  osade_success_checker: success_checker_f2,
  number_of_generation_parameter_result_saved: 100
)

de.oracle_simulate(oracle_f2, success_checker_f2)
