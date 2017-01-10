class Parameter
  ATTRIBUTES = %i(magnification_rate use_mutated_component_rate)
  attr_reader(*ATTRIBUTES)
  attr_accessor :calculated_value_diff

  def initialize(magnification_rate, use_mutated_component_rate)
    @magnification_rate = magnification_rate
    @use_mutated_component_rate = use_mutated_component_rate
  end
end
