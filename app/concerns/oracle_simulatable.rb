module OracleSimulatable
  def oracle_simulate(oracle_function, success_checker)
    raise "'create_parameter' must be implemented." unless respond_to?(:create_parameter, true)
    raise "'update_parameters' must be implemented." unless respond_to?(:update_parameters, true)

    @oracle_function = oracle_function
    @success_checker = success_checker

    oracle_simulation_max_count = max_generation
    oracle_simulation_count = 0

    @time = Benchmark.realtime do
      set_initial_vectors

      while oracle_simulation_count < oracle_simulation_max_count
        oracle_parameter = create_oracle_parameter(oracle_simulation_count / oracle_simulation_max_count)
        parameter = create_parameter
        check_parameter_success(oracle_parameter, parameter)
        update_parameters
        oracle_simulation_count += 1
      end
    end
  end

  private

  def create_oracle_parameter(x)
    Parameter.new(
      @oracle_function.calc(x),
      @oracle_function.calc(x)
    )
  end

  def check_parameter_success(oracle_parameter, parameter)
    if @success_checker.succeeded?(oracle_parameter, parameter)
      @success_parameters << parameter
    else
    end
  end
end
