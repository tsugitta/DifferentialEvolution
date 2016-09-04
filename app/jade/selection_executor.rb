require_relative '../de.rb'
require_relative '../de/selection_executor.rb'

class JADE < DE; end

class JADE::SelectionExecutor < DE::SelectionExecutor
  attr_reader :archived_vectors, :success_parameters

  def create_selected_vectors
    @archived_vectors = []
    @success_parameters = []
    super
  end

  private

  def better_vector(p_v, c_v)
    if p_v.calculated_value < c_v.calculated_value
      p_v
    else
      @archived_vectors << p_v
      @success_parameters << p_v.parameter
      c_v
    end
  end
end
