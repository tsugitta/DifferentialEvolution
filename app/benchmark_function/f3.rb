# Rastrigin
class BenchmarkFunction::F3 < BenchmarkFunction
  def option
    {
      initial_value_min: -100,
      initial_value_max:  100
    }
  end

  def calc(v, min: 0)
    check_vector_type(v)

    d = v.size
    z = h.lambda(dim: d, alpha: 10) * h.t_asy(h.t_osz(v), beta: 0.2)
    calculated_value = \
      10 * (d - z.map { |e| Math.cos(2 * Math::PI * e) }.inject(:+)) + z.norm**2 + min

    check_calculated_value_type(calculated_value)
    calculated_value
  end

  def label
    'F3(Rastrigin)'
  end

  private

  def dim(v)
    v.size
  end

  def h
    Helper
  end
end
