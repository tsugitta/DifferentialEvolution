# Attractive Sector
class BenchmarkFunction::F6 < BenchmarkFunction
  def calc(v)
    check_vector_type(v)

    z = z(v)
    s = s(z)
    sum = (0..z.size-1).map { |i| (s[i] * z[i]) ** 2 }.inject(:+)
    calculated_value = h.t_osz(sum ** 0.9) + @min

    check_calculated_value_type(calculated_value)
    calculated_value
  end

  def label
    'F6(Attractive Sector)'
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
    h.lambda(dim: v.size, alpha: 10) * (v - x_opt(v.size))
  end
end
