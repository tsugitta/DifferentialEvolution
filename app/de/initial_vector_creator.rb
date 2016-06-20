class DE end

class DE::InitialVectorCreator
  def self.create(length: nil, dimension: nil, min: nil, max: nil)
    raise 'length: Int must be passed' unless length.is_a?(Fixnum)
    new(dimension: dimension, min: min, max: max).create(length)
  end

  def initialize(dimension: nil, min: nil, max: nil)
    raise 'dimension: Int must be passed' unless dimension.is_a?(Fixnum)
    raise 'min and max must be passed' if min == nil || max == nil
    raise 'not min < max ' unless min < max
    @dimension = dimension
    @min = min.to_f
    @max = max.to_f
  end

  def create(length)
    Array.new(length) do
      Vector.elements(Array.new(@dimension) { Random.rand(@min..@max) }, false)
    end
  end
end
