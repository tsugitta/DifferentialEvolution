# Buche-Rastrigin
class BenchmarkFunction::F4 < BenchmarkFunction
  def option
    {
      initial_value_min: -100,
      initial_value_max:  100
    }
  end

  def calc(v, min: 0)
    check_vector_type(v)

    z = z(v)
    # also needs penalty function
    calculated_value = \
      10 * (dim(v) - z.map { |e| Math.cos(2 * Math::PI * e) }.inject(:+)) + \
      z.norm**2 + 100 * h.penalty(v) + min

    check_calculated_value_type(calculated_value)
    calculated_value
  end

  def label
    'F4(Buche-Rastrigin)'
  end

  private

  def dim(v)
    v.size
  end

  def h
    Helper
  end

  def z(v)
    osz = h.t_osz(v)
    osz.map.with_index do |e, i|
      s = 10**(0.5 * i / (dim(v) - 1))
      s *= 10 if e > 0 && i.even?
      e * s
    end
  end
end
