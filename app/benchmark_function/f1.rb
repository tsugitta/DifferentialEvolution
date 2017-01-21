# Sphere
class BenchmarkFunction::F1 < BenchmarkFunction
  def calc(v)
    check_vector_type(v)
    calculated_value = (v - x_opt(v.size)).norm ** 2 + @min

    check_calculated_value_type(calculated_value)
    calculated_value
  end

  def label
    'F1(Sphere)'
  end
end
