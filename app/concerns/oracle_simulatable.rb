module OracleSimulatable
  def oracle_simulate(oracle_function, success_checker)
    raise "'create_parameter' must be implemented." unless respond_to?(:create_parameter, true)
    raise "'update_parameters' must be implemented." unless respond_to?(:update_parameters, true)

    @oracle_function = oracle_function
    @success_checker = success_checker

    @oracle_simulation_max_count = max_generation
    oracle_simulation_count = 0

    @oracle_parameters = []
    @parameters = []

    while oracle_simulation_count < @oracle_simulation_max_count
      @success_parameters = []
      oracle_parameter = create_oracle_parameter(oracle_simulation_count.to_f / @oracle_simulation_max_count.to_f)
      parameter = create_parameter
      check_parameter_success(oracle_parameter, parameter)

      @oracle_parameters << oracle_parameter
      @parameters << @parameter_means.dup

      update_parameters
      oracle_simulation_count += 1
    end

    plot_parameters
  end

  private

  def plot_parameters
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title 'Oracle simulation'
        plot.xlabel 'generation'
        plot.ylabel 'parameter'

        x_plots = (1..@oracle_simulation_max_count).to_a

        parameter_plots = @parameters.map { |p| p.magnification_rate }
        plot.data << Gnuplot::DataSet.new([x_plots, parameter_plots]) do |ds|
          ds.with = 'lines'
          ds.title = 'parameter'
        end

        oracle_plots = @oracle_parameters.map { |p| p.magnification_rate }
        plot.data << Gnuplot::DataSet.new([x_plots, oracle_plots]) do |ds|
          ds.with = 'lines'
          ds.title = 'oracle parameter'
        end
      end
    end
  end

  def create_oracle_parameter(x)
    y = Parameter.new(
      @oracle_function.calc(x),
      @oracle_function.calc(x)
    )
    y
  end

  def check_parameter_success(oracle_parameter, parameter)
    if @success_checker.succeeded?(oracle_parameter, parameter)
      @success_parameters << parameter
    else
    end
  end
end
