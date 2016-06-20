require 'matrix'

class DE end

class DE::MutatedVectorCreator
  def self.create_from(vectors, magnification_rate: nil)
    new(vectors, magnification_rate: magnification_rate).create
  end

  def initialize(vectors, magnification_rate: nil)
    raise 'Mutation\'s magnification_rate must be specified.' if magnification_rate == nil
    @vectors = vectors
    @magnification_rate = magnification_rate
  end

  def create
    mutated_vectors = []

    @vectors.each do |parent_v|
      v_a, v_b, v_c = select_three_vectors_except(parent_v)
      mutated_vector = v_a + (v_b - v_c) * @magnification_rate
      mutated_vectors << mutated_vector
    end

    mutated_vectors
  end

  private

  def select_three_vectors_except(parent_v)
    selected_vectors_with_rest = @vectors.sample(4)
    selected_vectors_with_rest
      .reject { |v| v == parent_v }
      .sample(3)
  end
end
