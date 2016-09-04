class Parameter
  ATTRIBUTES = %i(magnification_rate use_mutated_component_rate)
  attr_accessor(*ATTRIBUTES)

  def initialize(magnification_rate, use_mutated_component_rate)
    @magnification_rate = magnification_rate
    @use_mutated_component_rate = use_mutated_component_rate
  end

  def dup
    Parameter.new(magnification_rate, use_mutated_component_rate)
  end
end
