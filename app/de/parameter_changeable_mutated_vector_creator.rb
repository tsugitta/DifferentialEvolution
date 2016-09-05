require_relative './mutated_vector_creator.rb'

class DE::ParameterChangeableMutatedVectorCreator < DE::MutatedVectorCreator
  private

  def set_use_magnification_rate(p_v)
    @magnification_rate = p_v.parameter.magnification_rate
  end
end
