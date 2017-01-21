# Rosenbrock Function, original
class BenchmarkFunction::F8 < BenchmarkFunction
  def calc(v)
    check_vector_type(v)

    z = z(v)
    calculated_value = \
      (0..v.size-2).map { |i| 100 * (z[i]**2 - z[i+1])**2 + (z[i] - 1)**2 }.inject(:+) + @min

    check_calculated_value_type(calculated_value)
    calculated_value
  end

  def label
    'F8(Rosenbrock Function, original)'
  end

  private

  def h
    Helper
  end

  def s(z)
    z.map.with_index do |e, i|
      z[i] * x_opt(z.size)[i] > 0 ? 10**2 : 1
    end
  end

  def z(v)
    [1, Math.sqrt(v.size) / 8].max * (v - x_opt(v.size)) + h.ones(dim: v.size)
  end
end
