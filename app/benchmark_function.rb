require_relative './benchmark_function/f1.rb'

class BenchmarkFunction
  def calc(v)
    raise 'Benchmark.calc must be passed Vector type' unless v.is_a?(Vector)
  end
end
