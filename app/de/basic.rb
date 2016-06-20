class DE end

class DE::Basic < DE
  def exec
    set_initial_vectors

    max_generation.times do |generation|
      exec_mutation
      exec_crossover
      exec_selection
    end
  end
end
