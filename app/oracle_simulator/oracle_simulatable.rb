module OracleSimulatable
  def oracle_simulate(oracle_function, success_checker)
    raise "'create_parameter' must be implemented." unless respond_to?(:create_parameter, true)
    raise "'update_parameters' must be implemented." unless respond_to?(:update_parameters, true)

    @oracle_function = oracle_function
    @success_checker = success_checker

    @oracle_simulation_max_count = max_generation

    @oracle_parameters = []
    @parameters = []

    @check_count = 0
    @check_success_count = 0

    (1..@oracle_simulation_max_count).each do |oracle_simulation_count|
      output_current_simulation_count(oracle_simulation_count)
      @success_parameters = []
      oracle_parameter = create_oracle_parameter(oracle_simulation_count.to_f / @oracle_simulation_max_count.to_f)

      @oracle_parameters << oracle_parameter
      @parameters << @parameter_means

      (1..number_of_vectors).each do |vector_number|
        parameter = create_parameter
        check_parameter_success(oracle_parameter, parameter)
      end

      update_parameters
    end

    plot_parameters
  end

  private

  def output_current_simulation_count(count)
    print "\rgeneration: #{count}/#{@oracle_simulation_max_count}"
    print "\rdone. printing the result..                       \n" if count >= @oracle_simulation_max_count
  end

  def oracle_parameter_information
    information = [
      "#{self.class}, oracle f: #{@oracle_function.label}, checker f: #{@success_checker.label}, N: #{number_of_vectors}, generation: #{@oracle_simulation_max_count}",
      '\n' + "initial R: #{initial_magnification_rate_mean}, initial C: #{initial_use_mutated_component_rate_mean}, r: #{sprintf('%.3f', @check_success_count.to_f / @check_count.to_f)}",
    ]
    information << ('\n' + "p for pbest: #{p_to_use_current_to_pbest_mutation}, archive size: #{archived_vectors_size}") if use_archive?
    information.join
  end

  def plot_parameters
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title oracle_parameter_information
        plot.xlabel 'generation'
        plot.ylabel 'parameter'

        x_plots = (1..@oracle_simulation_max_count).to_a

        parameter_magnification_rate_plots = @parameters.map { |p| p.magnification_rate }
        plot.data << Gnuplot::DataSet.new([x_plots, parameter_magnification_rate_plots]) do |ds|
          ds.with = 'lines'
          ds.title = 'magnification-rate mean'
        end

        parameter_use_mutated_component_rate_plots = @parameters.map { |p| p.use_mutated_component_rate }
        plot.data << Gnuplot::DataSet.new([x_plots, parameter_use_mutated_component_rate_plots]) do |ds|
          ds.with = 'lines'
          ds.title = 'use-mutated-component-rate mean'
        end

        oracle_magnification_rate_plots = @oracle_parameters.map { |p| p.magnification_rate }
        plot.data << Gnuplot::DataSet.new([x_plots, oracle_magnification_rate_plots]) do |ds|
          ds.with = 'lines'
          ds.title = 'oracle magnification-rate'
        end

        oracle_use_mutated_component_rate_plots = @oracle_parameters.map { |p| p.magnification_rate }
        plot.data << Gnuplot::DataSet.new([x_plots, oracle_use_mutated_component_rate_plots]) do |ds|
          ds.with = 'lines'
          ds.title = 'oracle use-mutated-component-rate'
        end
      end
    end
  end

  def create_oracle_parameter(x)
    Parameter.new(
      @oracle_function.calc(x),
      @oracle_function.calc(x)
    )
  end

  def check_parameter_success(oracle_parameter, parameter)
    @check_count += 1

    if @success_checker.succeeded?(oracle_parameter, parameter)
      @check_success_count += 1
      @success_parameters << parameter
    end
  end
end
