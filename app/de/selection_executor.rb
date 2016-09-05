class DE end

class DE::SelectionExecutor
  attr_reader :evaluation_count, :archived_vectors

  def initialize(parents: nil, children: nil, f: nil, evaluation_rest: nil)
    raise 'SelectionExecutor\'s arguments must be passed' if [parents, children, f, evaluation_rest].include?(nil)
    @parents = parents
    @children = children
    @f = f
    @evaluation_rest = evaluation_rest
    @evaluation_count = 0
    @archived_vectors = []
  end

  def create_selected_vectors
    selected_vectors = []

    vector_count.times do |i|
      p_v, c_v = @parents[i], @children[i]

      evaluate(p_v) unless p_v.calculated_value
      break if @evaluation_count >= @evaluation_rest
      evaluate(c_v)

      selected_vectors << better_vector(p_v, c_v)
      break if @evaluation_count >= @evaluation_rest
    end

    return selected_vectors if selected_vectors.size == vector_count
    selected_vectors + @parents[selected_vectors.size..-1]
  end

  private

  def better_vector(p_v, c_v)
    if p_v.calculated_value <= c_v.calculated_value
      p_v
    else
      @archived_vectors << p_v
      c_v
    end
  end

  def vector_count
    @vector_count ||= @parents.size
  end

  def evaluate(v)
    v.calculate_with(@f)
    @evaluation_count += 1
  end
end
