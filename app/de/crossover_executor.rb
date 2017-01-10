class DE::CrossoverExecutor
  def initialize(parent_vectors: nil, mutated_vectors: nil, parameters: nil, crossover_method: nil)
    raise 'parent and mutated vectors must be passed' if parent_vectors == nil || mutated_vectors == nil
    @parent_vectors = parent_vectors
    @mutated_vectors = mutated_vectors
    @parameters = parameters
    @crossover_method = crossover_method
  end

  def create_children
    children = []

    vector_count.times do |i|
      p_v, m_v, parameter = @parent_vectors[i], @mutated_vectors[i], @parameters[i]

      crossovered_vector = case @crossover_method
      when 'binomial'
        binomial_crossovered_vector(p_v, m_v, parameter)
      when 'exponential'
        exponential_crossovered_vector(p_v, m_v, parameter)
      else
        raise "crossover method '#{@crossover_method}' is invalid."
      end

      children << crossovered_vector
    end

    children
  end

  private

  def binomial_crossovered_vector(p_v, m_v, parameter)
    child_components = []
    must_use_mutated_index = rand(dim) - 1

    dim.times do |d|
      child_components[d] = if d == must_use_mutated_index || use_mutated_component?(parameter)
        m_v[d]
      else
        p_v[d]
      end
    end

    Vector.elements(child_components, false)
  end

  def exponential_crossovered_vector(p_v, m_v, parameter)
    child_components = p_v.to_a
    k, j = 1, rand(dim)

    begin
      child_components[j] = m_v[j]
      k += 1
      j = (j + 1) % dim
    end while use_mutated_component?(parameter) && k < dim

    Vector.elements(child_components, false)
  end

  def set_use_mutated_component_rate(p_v)
    # override this and set @use_mutated_component_rate if needed
  end

  def vector_count
    @vector_count ||= @parent_vectors.size
  end

  def dim
    @dim ||= @parent_vectors.first.size
  end

  def use_mutated_component?(parameter)
    rand < parameter.use_mutated_component_rate
  end
end
