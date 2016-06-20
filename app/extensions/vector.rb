class Vector
  attr_reader :calculated_value

  def calculate_with(f)
    return if f == @calculated_function
    @calculated_function = f
    @calculated_value = f.calc(self)
  end
end
