module OracleSimulatable
  def oracle_simulate(oracle_function, success_checker)
    raise "'create_parameter' must be implemented." unless respond_to?(:create_parameter, true)
    raise "'update_parameters' must be implemented." unless respond_to?(:update_parameters, true)
    raise "'save_parameter_to_history' must be implemented." unless respond_to?(:save_parameter_to_history, true)
    raise "'parameter_transition_plot_value' must be implemented." unless respond_to?(:parameter_transition_plot_value, true)

    @oracle_function = oracle_function
    @success_checker = success_checker

    @oracle_parameters = []

    @check_count = 0
    @check_success_count = 0

    @generation = 1

    loop do
      output_current_simulation_count(@generation)
      save_parameter_to_history

      break if @generation >= max_generation

      @success_parameters = []
      oracle_parameter = create_oracle_parameter(@generation.to_f / max_generation.to_f)

      @oracle_parameters << oracle_parameter

      (1..number_of_vectors).each do |vector_number|
        parameter = create_parameter
        check_parameter_success(oracle_parameter, parameter)
      end

      update_parameters
      @generation += 1
    end

    plot_parameters
  end

  private

  def output_current_simulation_count(count)
    print "\rgeneration: #{count}/#{max_generation}"
    print "\rdone. printing the result..\n" if count >= max_generation
  end

  def oracle_parameter_information
    information = [
      "#{self.class}, oracle f: #{@oracle_function.label}, checker f: #{@success_checker.label}, N: #{number_of_vectors}, generation: #{max_generation}, r: #{sprintf('%.3e', @check_success_count.to_f / @check_count.to_f)}"
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

        plot.data << Gnuplot::DataSet.new(parameter_transition_plot_value[:magnification_rate]) do |ds|
          ds.with = 'lines' if parameter_transition_plot_value[:magnification_rate][0].size == max_generation
          ds.title = 'magnification-rate mean'
        end

        plot.data << Gnuplot::DataSet.new(parameter_transition_plot_value[:use_mutated_component_rate]) do |ds|
          ds.with = 'lines' if parameter_transition_plot_value[:use_mutated_component_rate][0].size == max_generation
          ds.title = 'use-mutated-component-rate mean'
        end

        x_plots = (1..max_generation).to_a

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
