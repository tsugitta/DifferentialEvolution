class DE end

class DE::MutatedVectorCreator
  attr_reader :evaluation_count

  def initialize(vectors, magnification_rate: nil, mutation_method: :rand_1, p: nil, f: nil, archived_vectors: nil)
    @vectors = vectors
    @magnification_rate = magnification_rate
    @mutation_method = mutation_method
    @p = p
    @f = f
    @archived_vectors = archived_vectors
    @evaluation_count = 0
  end

  def create
    case @mutation_method
    when :rand_1
      rand_1_mutated_vectors
    when :rand_2
      rand_2_mutated_vectors
    when :current_to_pbest_1
      current_to_pbest_1_mutated_vectors
    else
      raise "mutation_method: '#{@mutation_method}' is invalid."
    end
  end

  private

  # rand/1 mutation
  def rand_1_mutated_vectors
    mutated_vectors = []

    @vectors.each do |parent_v|
      mutated_vectors << rand_1_mutated_vector(parent_v)
    end

    mutated_vectors
  end

  def rand_1_mutated_vector(parent_v)
    v_a, v_b, v_c = select_vectors_except(parent_v, 3)
    v_a + (v_b - v_c) * @magnification_rate
  end

  # rand/2 mutation
  def rand_2_mutated_vectors
    raise 'Mutation\'s magnification_rate must be specified.' if magnification_rate == nil
    mutated_vectors = []

    @vectors.each do |parent_v|
      v_a, v_b, v_c, v_d, v_e = select_vectors_except(parent_v, 5)
      mutated_vector = v_a + (v_b - v_c) * @magnification_rate + (v_d - v_e) * @magnification_rate
      mutated_vectors << mutated_vector
    end

    mutated_vectors
  end

  # current-to-pbest/1 mutation
  def current_to_pbest_1_mutated_vectors
    raise 'p must be passed if using pbest.' if @p == nil
    raise 'f must be passed if using pbest.' if @f == nil
    raise 'archived_vectors must be passed if using pbest.' if @archived_vectors == nil

    mutated_vectors = []
    p_candidates = vectors_sorted_desc_by_score.first([(@p * vector_size).floor, 2].max)
    v_b_candidates = @vectors + @archived_vectors

    @vectors.each do |parent_v|
      mutated_vectors << current_to_pbest_1_mutated_vector(parent_v, p_candidates, v_b_candidates)
    end

    mutated_vectors
  end

  def current_to_pbest_1_mutated_vector(parent_v, p_candidates, v_b_candidates)
    v_p = p_candidates.sample
    v_a = select_vectors_except(parent_v, 1).first
    v_b = v_b_candidates.sample
    parent_v + (v_p - parent_v) * @magnification_rate + (v_a - v_b) * @magnification_rate
  end

  def select_vectors_except(parent_v, count)
    begin
      selected_vectors_with_rest = @vectors.sample(count + 1)
      selected_vectors = selected_vectors_with_rest
        .reject { |v| v == parent_v }
        .sample(count)
    end while selected_vectors.size < count

    selected_vectors
  end

  def vectors_sorted_desc_by_score
    @vectors.sort do |v_a, v_b|
      evaluate(v_a) unless v_a.calculated_value
      evaluate(v_b) unless v_b.calculated_value
      v_a.calculated_value <=> v_b.calculated_value # the lower value, the higher score
    end
  end

  def vector_size
    @vector_size ||= @vectors.size
  end

  def evaluate(v)
    v.calculate_with(@f)
    @evaluation_count += 1
  end
end
