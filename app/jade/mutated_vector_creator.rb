require_relative '../de.rb'
require_relative '../de/mutated_vector_creator.rb'

class JADE < DE; end

class JADE::MutatedVectorCreator < DE::MutatedVectorCreator
  def create
    @mutation_method = :current_to_pbest_1
    super
  end

  private

  def current_to_pbest_1_mutated_vector(parent_v, p_candidates, v_b_candidates)
    @magnification_rate = parent_v.parameter.magnification_rate
    super(parent_v, p_candidates, v_b_candidates)
  end
end
