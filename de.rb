require_relative './de/basic.rb'

class DE
  DEFAULT_OPTION = {
    dimension: 2,
    number_of_vectors: 100,
    max_generation: 10000,
    initial_value_min: -100,
    initial_value_max: 100
  }

  attr_reader :f, :vectors
  attr_reader *DEFAULT_OPTION.keys

  def initialize(f, option = {})
    if f == nil || !f.is_a?(Benchmark)
      raise 'DE initialize must be passed the benchmark func as the first argument.'
    end

    @f = f
    set_option(DEFAULT_OPTION.merge(f.option).merge(option))
  end

  def exec
    raise 'DE#execute must be overridden.'
  end

  private

  def set_option(option)
    option.each do |k, v|
      eval "@#{k} = v"
    end
  end

  def set_initial_vectors
    @vectors = DE::InitialVectorCreator.create \
      length: number_of_vectors,
      dimension: dimension,
      min: initial_value_min,
      max: initial_value_max
  end
end
