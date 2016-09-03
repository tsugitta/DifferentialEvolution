require_relative '../de.rb'
require_relative '../de/selection_executor.rb'

class JADE < DE; end

class JADE::SelectionExecutor < DE::SelectionExecutor
  attr_reader :archived_vectors, :success_magnification_rates, :success_use_mutated_component_rates

  def create_selected_vectors
    @archived_vectors = []
    @success_magnification_rates = []
    @success_use_mutated_component_rates = []
    super
  end

  private

  def better_vector(p_v, c_v)
    if p_v.calculated_value < c_v.calculated_value
      p_v
    else
      @archived_vectors << p_v
      @success_magnification_rates << p_v.magnification_rate
      @success_use_mutated_component_rates << p_v.use_mutated_component_rate
      c_v
    end
  end
end
