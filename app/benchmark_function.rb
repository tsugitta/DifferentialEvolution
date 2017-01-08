class BenchmarkFunction
  def calc(v)
    raise NotImplementedError
  end

  def check_vector_type(vector)
    raise 'Benchmark.calc must be passed Vector type' unless vector.is_a?(Vector)
  end

  def check_calculated_value_type(value)
    if [Float::INFINITY, Float::NAN].include?(value)
      raise 'Cannot continue because of calculated value has become INFINITY or NAN'
    end
  end
end

require_relative './benchmark_function/index.rb'
