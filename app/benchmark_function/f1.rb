class BenchmarkFunction end

# Sphere
class BenchmarkFunction::F1 < BenchmarkFunction
  def option
    {
      initial_value_min: -100,
      initial_value_max:  100
    }
  end

  def calc(v)
    super(v)
    v.map{ |i| i ** 2 }.inject(:+)
  end

  def label
    'F1(Sphere)'
  end
end
