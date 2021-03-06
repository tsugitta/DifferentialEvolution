class DE::InitialVectorCreator
  def initialize(dimension: nil, min: nil, max: nil)
    raise 'dimension: Int must be passed' unless dimension.is_a?(Integer)
    raise 'min and max must be passed' if min == nil || max == nil
    raise 'not min < max ' unless min < max
    @dimension = dimension
    @min = min.to_f
    @max = max.to_f
  end

  def create(length)
    raise 'length: Int must be passed' unless length.is_a?(Integer)

    Array.new(length) do
      Vector.elements \
        Array.new(@dimension) { Random.rand(@min..@max) },
        false
    end
  end
end
