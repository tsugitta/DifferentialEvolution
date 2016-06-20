require_relative './initial_vector_creator.rb'

class DE end

class DE::Basic < DE
  def exec
    set_initial_vectors
  end
end
