require_relative './benchmark/f1.rb'

class Benchmark
  def calc(v)
    raise 'Benchmark.calc must be passed Vector type' unless v.is_a?(Vector)
  end
end
