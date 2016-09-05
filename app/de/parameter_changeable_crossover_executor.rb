require_relative './crossover_executor.rb'

class DE::ParameterChangeableCrossoverExecutor < DE::CrossoverExecutor
  private

  def set_use_mutated_component_rate(p_v)
    @use_mutated_component_rate = p_v.parameter.use_mutated_component_rate
  end
end
