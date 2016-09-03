require_relative './de.rb'
require_relative './jade/mutated_vector_creator.rb'
require_relative './jade/crossover_executor.rb'
require_relative './jade/selection_executor.rb'

class JADE < DE
  JADE_DEFAULT_OPTION = {
    initial_magnification_rate_mean: 0.5,
    initial_use_mutated_component_rate_mean: 0.5,
    normal_distribution_sigma: 0.1,
    cauchy_distribution_gamma: 0.1,
    p_to_use_current_to_pbest_mutation: 0.05,
    archived_vectors_size: 50,
    c_to_use_new_rate_mean_weight: 0.1
  }

  attr_reader *JADE_DEFAULT_OPTION.keys

  def initialize(f, option = {})
    option = JADE_DEFAULT_OPTION.merge(option)
    option[:archived_vectors_size] = DEFAULT_OPTION[:number_of_vectors]

    super(f, option)

    @magnification_rate_mean = initial_magnification_rate_mean
    @use_mutated_component_rate_mean = initial_use_mutated_component_rate_mean
    @success_magnification_rates = []
    @success_use_mutated_component_rates = []
    @archived_vectors = []
  end

  private

  def exec_initialization_of_beginning_generation
    vectors.each do |vector|
      vector.magnification_rate = Random.rand_following_normal_from_0_to_1 \
        @magnification_rate_mean,
        normal_distribution_sigma
      vector.use_mutated_component_rate = Random.rand_following_cauchy_from_0_to_1 \
        @use_mutated_component_rate_mean,
        cauchy_distribution_gamma
    end
  end

  def exec_mutation
    mutated_vector_creator = (self.class)::MutatedVectorCreator.new \
      @vectors,
      p: p_to_use_current_to_pbest_mutation,
      f: f,
      archived_vectors: @archived_vectors
    @mutated_vectors = mutated_vector_creator.create
    @evaluation_count += mutated_vector_creator.evaluation_count
  end

  def exec_selection
    selection_executor = super
    @success_magnification_rates += selection_executor.success_magnification_rates
    @success_use_mutated_component_rates += selection_executor.success_use_mutated_component_rates
    update_archives_with(selection_executor.archived_vectors)
  end

  def update_archives_with(new_archives)
    new_archives.each do |new_vector|
      if @archived_vectors.size >= archived_vectors_size
        @archived_vectors[rand(archived_vectors_size)] = new_vector
      else
        @archived_vectors << new_vector
      end
    end
  end

  def exec_termination_of_ending_generation
    c = c_to_use_new_rate_mean_weight
    @magnification_rate_mean = (1 - c) * @magnification_rate_mean + c * MathCalculator.lehmer_mean(@success_magnification_rates)
    @use_mutated_component_rate_mean = (1 - c) * @use_mutated_component_rate_mean + c * MathCalculator.arithmetic_mean(@success_use_mutated_component_rates)
  end
end
