class DE::Plotter
  def add_min_value_transition(label, min_values)
    min_value_transitions << {
      label: label,
      min_values: min_values
    }
  end

  def plot_min_value_transitions(title)
    return if min_value_transitions.empty?

    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title title
        plot.xlabel 'generation'
        plot.ylabel 'value'
        plot.set 'logscale y'
        plot.set 'format y "%1.1e"'

        x = (1..min_value_transitions.first[:min_values].size).to_a

        min_value_transitions.each do |min_value_transition|
          plot.data << Gnuplot::DataSet.new([x, min_value_transition[:min_values]]) do |ds|
            ds.with = 'lines'
            ds.title = "#{min_value_transition[:label]} min value"
          end
        end
      end
    end
  end

  # line transition
  def add_parameter_transition(label, parameter_transition)
    parameter_transitions << {
      label: label,
      values: parameter_transition
    }
  end

  # dot transition
  def add_parameters_transition(label, parameters_transition)
    parameters_transitions << {
      label: label,
      values: parameters_transition
    }
  end

  def plot_parameter_transitions(plot_f: true, plot_c: true)
    return if parameter_transitions.empty? && parameters_transitions.empty?

    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title 'parameter transition'

        plot.xlabel 'generation'
        plot.ylabel 'value'
        plot.set 'key outside'
        plot.set 'style fill transparent solid 0.3 noborder'
        plot.set 'style circle radius 1.3'
        plot.set 'yrange [0:1]'

        # draw dots
        parameters_transitions.each do |parameters_transition|
          generation_array, f_array, c_array, rank_array = [], [], [], []

          parameters_transition[:values].each.with_index(1) do |parameters, generation|
            next if parameters.nil?

            parameters.sort_by(&:calculated_value_diff).each.with_index(1) do |p, i|
              generation_array << generation
              f_array << p.magnification_rate
              c_array << p.use_mutated_component_rate
              rank_array << i
            end
          end

          if plot_f
            plot.data << Gnuplot::DataSet.new([generation_array, f_array, rank_array]) do |ds|
              ds.title = "#{parameters_transition[:label]} F"
              ds.with = 'circles lc palette'
            end
          end

          if plot_c
            plot.data << Gnuplot::DataSet.new([generation_array, c_array, rank_array]) do |ds|
              ds.title = "#{parameters_transition[:label]} C"
              ds.with = 'circles lc palette'
            end
          end
        end

        # draw lines
        parameter_transitions.each do |parameter_transition|
          x = (1..parameter_transition[:values].size).to_a

          if plot_f
            plot.data << Gnuplot::DataSet.new([x, parameter_transition[:values].map(&:magnification_rate)]) do |ds|
              ds.with = 'lines'
              ds.title = "#{parameter_transition[:label]} F"
            end
          end

          if plot_c
            plot.data << Gnuplot::DataSet.new([x, parameter_transition[:values].map(&:use_mutated_component_rate)]) do |ds|
              ds.with = 'lines'
              ds.title = "#{parameter_transition[:label]} C"
            end
          end
        end
      end
    end
  end

  def plot_parameter_transitions_2d_animation
    parameters_transitions.each do |parameters_transition|
      Gnuplot.open do |gp|
        results_path = File.expand_path('../../results', __FILE__)
        gp << "set nokey\n"
        gp << "set term gif animate delay 0.5\n"
        gp << "set output \"#{results_path}/parameter_transition_#{Time.now.strftime('%Y-%m-%d_%H_%M_%S')}_#{parameters_transition[:label].gsub("\s", '_')}.gif\"\n"
        gp << "set xrange [0:1]\n"
        gp << "set yrange [0:1]\n"

        parameters_transition[:values].size.times do |i|
          Gnuplot::Plot.new(gp) do |plot|
            plot.title 'parameter transition'

            plot.xlabel 'F'
            plot.ylabel 'C'
            plot.set 'key outside'
            plot.set 'style fill transparent solid 0.5'

            parameters = parameters_transition[:values][i]
            next if parameters.nil?

            parameters = parameters.sort_by(&:calculated_value_diff)

            f_array = parameters.map { |p| p.magnification_rate }.compact
            c_array = parameters.map { |p| p.use_mutated_component_rate }.compact
            rank_array = (1..50).to_a

            plot.data << Gnuplot::DataSet.new([f_array, c_array, rank_array]) do |ds|
              ds.title = "generation #{i + 1}"
              ds.with = 'points pt 5 ps 1 lc palette'
            end
          end
        end
      end
    end
  end

  private

  def min_value_transitions
    @min_value_transitions ||= []
  end

  def parameter_transitions
    @parameter_transitions ||= []
  end

  def parameters_transitions
    @parameters_transitions ||= []
  end
end
