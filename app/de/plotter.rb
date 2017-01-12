class DE::Plotter
  def add_min_value_transition(label, min_values)
    min_value_transitions << {
      label: label,
      min_values: min_values
    }
  end

  def plot_min_value_transition
    return if min_value_transitions.empty?

    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title 'min value transition'
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

  def add_parameter_transition(label, all_parameter_transition, mean_parameter_transition)
    parameter_transitions << {
      label: label,
      all_parameter_transition: all_parameter_transition,
      mean_parameter_transition: mean_parameter_transition
    }
  end

  def plot_parameter_transition(plot_only_mean: true, plot_f: true, plot_c: true)
    return if parameter_transitions.empty?

    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title 'parameter transition'

        plot.xlabel 'generation'
        plot.ylabel 'value'
        plot.set 'key outside'
        plot.set 'style fill transparent solid 0.5'

        parameter_transitions.each do |parameter_transition|
          unless plot_only_mean
            generation_array = []
            f_array = []
            c_array = []
            rank_array = []

            parameter_transition[:all_parameter_transition].each.with_index(1) do |parameters, generation|
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
                ds.title = "#{parameter_transition[:label]} F"
                ds.with = 'points pt 5 ps 0.3 lc palette'
              end
            end

            if plot_c
              plot.data << Gnuplot::DataSet.new([generation_array, c_array, rank_array]) do |ds|
                ds.title = "#{parameter_transition[:label]} C"
                ds.with = 'points pt 5 ps 0.3 lc palette'
              end
            end
          end

          x = (1..parameter_transitions.first[:mean_parameter_transition].size).to_a

          if plot_f
            plot.data << Gnuplot::DataSet.new([x, parameter_transition[:mean_parameter_transition].map(&:magnification_rate)]) do |ds|
              # ds.with = 'lines lc rgbcolor "#114444"'
              ds.with = 'lines'
              ds.title = "#{parameter_transition[:label]} F mean"
            end
          end

          if plot_c
            plot.data << Gnuplot::DataSet.new([x, parameter_transition[:mean_parameter_transition].map(&:use_mutated_component_rate)]) do |ds|
              # ds.with = 'lines lc rgbcolor "#441111"'
              ds.with = 'lines'
              ds.title = "#{parameter_transition[:label]} C mean"
            end
          end
        end
      end
    end
  end

  def plot_parameter_transition_2d_animation
    return if parameter_transitions.empty?

    transition = parameter_transitions.first

    Gnuplot.open do |gp|
      gp << "set nokey\n"
      gp << "set term gif animate delay 0.5\n"
      gp << "set output \"results/parameter_transition_#{Time.now.strftime('%Y-%m-%d_%H_%M_%S')}.gif\"\n"
      gp << "set xrange [0:1]\n"
      gp << "set yrange [0:1]\n"

      transition[:mean_parameter_transition].size.times do |i|
        Gnuplot::Plot.new(gp) do |plot|
          plot.title 'parameter transition'

          plot.xlabel 'F'
          plot.ylabel 'C'
          plot.set 'key outside'
          plot.set 'style fill transparent solid 0.5'

          parameters = transition[:all_parameter_transition][i]
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

  private

  def min_value_transitions
    @min_value_transitions ||= []
  end

  def parameter_transitions
    @parameter_transitions ||= []
  end
end
