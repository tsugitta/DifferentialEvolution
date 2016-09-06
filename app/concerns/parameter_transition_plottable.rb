module ParameterTransitionPlottable
  def exec_termination_of_ending_calculation
    super
    plot_parameter_transition
  end

  def parameter_transition_plot_value
    raise "#{__METHOD__} must be implemented."
  end

  def plot_parameter_transition
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title parameter_information

        plot.xlabel 'generation'
        plot.ylabel 'parameter'

        plot.data << Gnuplot::DataSet.new(parameter_transition_plot_value[:magnification_rate]) do |ds|
          ds.with = 'lines' if parameter_transition_plot_value[:magnification_rate].first.size == @generation
          ds.title = 'magnification-rate mean'
        end

        plot.data << Gnuplot::DataSet.new(parameter_transition_plot_value[:use_mutated_component_rate]) do |ds|
          ds.with = 'lines' if parameter_transition_plot_value[:use_mutated_component_rate].first.size == @generation
          ds.title = 'use-mutated-component-rate mean'
        end
      end
    end
  end
end
