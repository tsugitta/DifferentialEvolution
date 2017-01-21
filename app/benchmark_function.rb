class BenchmarkFunction
  attr_reader :min

  def initialize(min_is_at_zero: false, min: 0)
    @min_is_at_zero = min_is_at_zero
    @min = min
  end

  def option
    {
      initial_value_min: -5,
      initial_value_max:  5
    }
  end

  def calc(v)
    raise NotImplementedError
  end

  def check_vector_type(vector)
    raise 'Benchmark.calc must be passed Vector type' unless vector.is_a?(Vector)
  end

  def check_calculated_value_type(value)
    if value == Float::INFINITY || value.to_f.nan?
      raise 'Cannot continue because of calculated value has become INFINITY or NAN'
    end
  end

  def x_opt(dim)
    @x_opt ||= begin
      if @min_is_at_zero
        array = Array.new(dim) { 0 }
      else
        array = Array.new(dim) { (rand - 0.5) * (4 / 0.5) }
      end
      Vector.elements(array, false)
    end
  end
end

require_relative './benchmark_function/index.rb'
