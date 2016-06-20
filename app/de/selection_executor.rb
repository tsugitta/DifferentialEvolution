class DE end

class DE::SelectionExecutor
  def self.create_selected_vectors(parents: nil, children: nil, f: nil)
    new(parents: parents, children: children, f: f).create_selected_vectors
  end

  def initialize(parents: nil, children: nil, f: nil)
    raise 'parents, children vectors and f must be passed' if [parents, children, f].include?(nil)
    @parents = parents
    @children = children
    @f = f
  end

  def create_selected_vectors
    selected_vectors = []

    vector_count.times do |i|
      p_v, c_v = @parents[i], @children[i]
      selected_vector = @f.calc(p_v) < @f.calc(c_v) ? p_v : c_v
      selected_vectors << selected_vector
    end

    selected_vectors
  end

  private

  def vector_count
    @vector_count ||= @parents.size
  end
end
