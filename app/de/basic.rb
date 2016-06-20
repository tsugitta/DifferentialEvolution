require_relative './initial_vector_creator.rb'
require_relative './mutated_vector_creator.rb'
require_relative './crossover_executor.rb'

class DE end

class DE::Basic < DE
  def exec
    set_initial_vectors

    max_generation.times do |generation|
      exec_mutation
      exec_crossover
    end
  end
end
