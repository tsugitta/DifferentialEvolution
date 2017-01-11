# Sphere
class BenchmarkFunction::F1 < BenchmarkFunction
  def calc(v, min: 0)
    check_vector_type(v)

    calculated_value = v.norm ** 2 + min

    check_calculated_value_type(calculated_value)
    calculated_value
  end

  def label
    'F1(Sphere)'
  end
end
