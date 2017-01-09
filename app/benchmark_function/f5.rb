# Linear Slope
class BenchmarkFunction::F5 < BenchmarkFunction
  def option
    {
      initial_value_min: -100,
      initial_value_max:  100
    }
  end

  def initialize(dim:)
    @dim = dim
  end

  def calc(v, min: 0)
    check_vector_type(v)

    s = s(v)
    z = z(v)
    calculated_value = \
      v.map.with_index { |e, i| 5 * s[i].abs - s[i] * z[i] }.inject(:+) + min

    check_calculated_value_type(calculated_value)
    calculated_value
  end

  def label
    'F5(Linear Slope)'
  end

  private

  def h
    Helper
  end

  def s(v)
    v.map.with_index do |e, i|
      h.sign(x_opt[i]) * 10**(i / @dim)
    end
  end

  def z(v)
    v.map.with_index do |e, i|
      next e if x_opt[i] * e < 5**2
      x_opt[i]
    end
  end

  def x_opt
    @x_opt ||= 5 * h.one_plus_minus(dim: @dim)
  end
end
