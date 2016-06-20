class DE end

class DE::CrossoverExecutor
  def self.create_children(parent_vectors: nil, mutated_vectors: nil, use_mutated_component_rate: nil)
    new(
      parent_vectors: parent_vectors,
      mutated_vectors: mutated_vectors,
      use_mutated_component_rate: use_mutated_component_rate
    ).create_children
  end

  def initialize(parent_vectors: nil, mutated_vectors: nil, use_mutated_component_rate: nil)
    raise 'parent and mutated vectors must be passed' if parent_vectors == nil || mutated_vectors == nil
    raise 'use_mutated_component_rate must be passed' if use_mutated_component_rate == nil
    @parent_vectors = parent_vectors
    @mutated_vectors = mutated_vectors
    @use_mutated_component_rate = use_mutated_component_rate
  end

  def create_children
    children = []

    vector_count.times do |i|
      p_v, m_v = @parent_vectors[i], @mutated_vectors[i]
      child_components = []

      dim.times do |d|
        child_components[d] = use_mutated_component? ? m_v[d] : p_v[d]
      end

      children << Vector.elements(child_components, false)
    end

    children
  end

  private

  def vector_count
    @vector_count ||= @parent_vectors.size
  end

  def dim
    @dim ||= @parent_vectors.first.size
  end

  def use_mutated_component?
    rand < @use_mutated_component_rate
  end
end
