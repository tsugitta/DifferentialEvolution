module ParameterTransitionPlottable
  def exec_termination_of_ending_calculation
    super
    plot_parameter_transition
  end

  def plot_parameter_transition
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title parameter_information

        plot.xlabel 'generation'
        plot.ylabel 'parameter'

        x_plots = (1..@generation).to_a

        parameter_magnification_rate_plots = @parameter_mean_history.map { |p| p.magnification_rate }
        plot.data << Gnuplot::DataSet.new([x_plots, parameter_magnification_rate_plots]) do |ds|
          ds.with = 'lines'
          ds.title = 'magnification-rate mean'
        end

        parameter_use_mutated_component_rate_plots = @parameter_mean_history.map { |p| p.use_mutated_component_rate }
        plot.data << Gnuplot::DataSet.new([x_plots, parameter_use_mutated_component_rate_plots]) do |ds|
          ds.with = 'lines'
          ds.title = 'use-mutated-component-rate mean'
        end
      end
    end
  end
end
