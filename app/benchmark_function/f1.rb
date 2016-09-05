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
    calculated_value = v.map{ |i| i ** 2 }.inject(:+)
    if [Float::INFINITY, Float::NAN].include?(calculated_value)
      raise 'Cannot continue because of calculated value has become INFINITY or NAN'
    end
    calculated_value
  end

  def label
    'F1(Sphere)'
  end
end
