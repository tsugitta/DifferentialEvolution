require_relative './selection_executor.rb'

class DE::ParameterSaveableSelectionExecutor < DE::SelectionExecutor
  attr_reader :success_parameters, :fail_parameters

  def create_selected_vectors
    @success_parameters = []
    @fail_parameters = []
    super
  end

  private

  def exec_when_child_vector_is_better(p_v, c_v)
    @success_parameters << p_v.parameter
  end

  def exec_when_parent_vector_is_better(p_v, c_v)
    @fail_parameters << p_v.parameter
  end
end
