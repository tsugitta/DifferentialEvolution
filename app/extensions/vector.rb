class Vector
  attr_reader :calculated_value
  attr_accessor :parameter

  def calculate_with(f)
    return @calculated_value if f == @calculated_function
    @calculated_function ||= f
    @calculated_value ||= f.calc(self)
  end
end
