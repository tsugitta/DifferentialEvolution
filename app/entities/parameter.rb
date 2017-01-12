class Parameter
  ATTRIBUTES = %i(magnification_rate use_mutated_component_rate)
  attr_reader(*ATTRIBUTES)
  attr_accessor :calculated_value_diff

  def initialize(magnification_rate, use_mutated_component_rate)
    if [magnification_rate, use_mutated_component_rate].include?(Float::INFINITY) ||
      magnification_rate.to_f.nan? || use_mutated_component_rate.to_f.nan?
      raise 'Cannot continue because attributes include INFINITY or NAN'
    end

    @magnification_rate = magnification_rate
    @use_mutated_component_rate = use_mutated_component_rate
    @calculated_value_diff = 0
  end
end
