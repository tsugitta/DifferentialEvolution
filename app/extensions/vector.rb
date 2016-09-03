class Vector
  attr_reader :calculated_value
  attr_accessor :magnification_rate, :use_mutated_component_rate

  def calculate_with(f)
    return @calculated_value if f == @calculated_function
    @calculated_function ||= f
    @calculated_value ||= f.calc(self)
  end

  def set_parameters(magnification_rate, use_mutated_component_rate)
    @magnification_rate = magnification_rate
    @use_mutated_component_rate = use_mutated_component_rate
  end
end
