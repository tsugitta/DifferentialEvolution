class Benchmark end

# Sphere
class Benchmark::F1 < Benchmark
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
end
