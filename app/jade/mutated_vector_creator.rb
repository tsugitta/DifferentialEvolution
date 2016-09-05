require_relative '../de.rb'
require_relative '../de/mutated_vector_creator.rb'

class JADE < DE; end

class JADE::MutatedVectorCreator < DE::MutatedVectorCreator
  private

  def rand_1_mutated_vector(parent_v)
    @magnification_rate = parent_v.parameter.magnification_rate
    super(parent_v)
  end

  def current_to_pbest_1_mutated_vector(parent_v, p_candidates, v_b_candidates)
    @magnification_rate = parent_v.parameter.magnification_rate
    super(parent_v, p_candidates, v_b_candidates)
  end
end
