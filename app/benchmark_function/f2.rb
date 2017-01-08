# Ellipsoidal
class BenchmarkFunction::F2 < BenchmarkFunction
  def option
    {
      initial_value_min: -100,
      initial_value_max:  100
    }
  end

  def calc(v, min: 0)
    check_vector_type(v)

    z = Helper.t_osz(v)
    calculated_value = z.map.with_index do |e, i|
      10**(6 * (i / (dim(v) - 1))) * e**2
    end.inject(:+) + min

    check_calculated_value_type(calculated_value)
    calculated_value
  end

  def label
    'F2(Ellipsoidal)'
  end

  private

  def dim(v)
    v.size
  end
end
