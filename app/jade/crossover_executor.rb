require_relative '../de.rb'
require_relative '../de/crossover_executor.rb'

class JADE < DE; end

class JADE::CrossoverExecutor < DE::CrossoverExecutor
  private

  def binomial_crossovered_vector(p_v, m_v)
    @use_mutated_component_rate = p_v.parameter.use_mutated_component_rate
    super(p_v, m_v)
  end
end
