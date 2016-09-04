class DE::CrossoverExecutor
  def initialize(parent_vectors: nil, mutated_vectors: nil, use_mutated_component_rate: nil, crossover_method: :binomial)
    raise 'parent and mutated vectors must be passed' if parent_vectors == nil || mutated_vectors == nil
    @parent_vectors = parent_vectors
    @mutated_vectors = mutated_vectors
    @use_mutated_component_rate = use_mutated_component_rate
    @crossover_method = crossover_method
  end

  def create_children
    children = []

    vector_count.times do |i|
      p_v, m_v = @parent_vectors[i], @mutated_vectors[i]

      crossovered_vector = case @crossover_method
      when :binomial
        binomial_crossovered_vector(p_v, m_v)
      when :exponential
        exponential_crossovered_vector(p_v, m_v)
      else
        raise "crossover method '#{@crossover_method}' is invalid."
      end

      children << crossovered_vector
    end

    children
  end

  private

  def binomial_crossovered_vector(p_v, m_v)
    child_components = []
    must_use_mutated_index = rand(dim) - 1

    dim.times do |d|
      child_components[d] = if d == must_use_mutated_index || use_mutated_component?
        m_v[d]
      else
        p_v[d]
      end
    end

    Vector.elements(child_components, false)
  end

  def exponential_crossovered_vector(p_v, m_v)
    child_components = p_v.to_a
    k, j = 1, rand(dim)

    begin
      child_components[j] = m_v[j]
      k += 1
      j = (j + 1) % dim
    end while use_mutated_component? && k < dim

    Vector.elements(child_components, false)
  end

  def vector_count
    @vector_count ||= @parent_vectors.size
  end

  def dim
    @dim ||= @parent_vectors.first.size
  end

  def use_mutated_component?
    raise 'use_mutated_component_rate must be passed' if @use_mutated_component_rate == nil
    rand < @use_mutated_component_rate
  end
end
