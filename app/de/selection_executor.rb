class DE::SelectionExecutor
  attr_reader :evaluation_count, :archived_vectors, :value_assigned_parameters

  def initialize(parents: nil, children: nil, parameters: nil, f: nil, evaluation_rest: nil)
    raise 'SelectionExecutor\'s arguments must be passed' if [parents, children, f, evaluation_rest].include?(nil)
    @parents = parents
    @children = children
    @value_assigned_parameters = parameters.map { |p| p.dup }
    @f = f
    @evaluation_rest = evaluation_rest
    @evaluation_count = 0
    @archived_vectors = []
  end

  def create_selected_vectors
    selected_vectors = []

    vector_count.times do |i|
      p_v, c_v, parameter = @parents[i], @children[i], @value_assigned_parameters[i]

      evaluate(p_v) unless p_v.calculated_value
      break if @evaluation_count >= @evaluation_rest
      evaluate(c_v)

      selected_vectors << better_vector(p_v, c_v, parameter)
      break if @evaluation_count >= @evaluation_rest
    end

    return selected_vectors if selected_vectors.size == vector_count
    selected_vectors + @parents[selected_vectors.size..-1]
  end

  private

  def better_vector(p_v, c_v, parameter)
    parameter.calculated_value_diff = c_v.calculated_value - p_v.calculated_value

    if parameter.calculated_value_diff >= 0
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
