class BenchmarkFunction::ShapeViewer
  DOT_COUNT_ON_A_POSITIVE_LINE = 200

  def show(f:, max: 30, map: false)
    Gnuplot.open do |gp|
      Gnuplot::SPlot.new( gp ) do |plot|
        plot.title f.label
        plot.xlabel "x"
        plot.ylabel "y"

        plot.set "dgrid3d 30,30"
        plot.set "hidden3d"
        plot.set "style fill  transparent solid 0.60 border"
        # show 2d mapping
        plot.set "view map" if map

        xs, ys, zs = [], [], []

        d = DOT_COUNT_ON_A_POSITIVE_LINE
        (-d..d).each do |i|
          (-d..d).each do |j|
            x = max.to_f * i.to_f / d.to_f
            y = max.to_f * j.to_f / d.to_f
            # binding.pry
            v = Vector[x, y]

            xs << x
            ys << y
            zs << f.calc(v)
          end
        end

        plot.data << Gnuplot::DataSet.new( [xs, ys, zs] ) do |ds|
          ds.with = "pm3d"
          ds.notitle
        end
      end
    end
  end

  # show 2d graph with fixing one axis value to 0
  def show_with_2d(f:, max: 30)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title "#{f.label} fixed x"
        plot.xlabel 'y'
        plot.ylabel 'value'
        # plot.set 'format z "%1.1e"'

        d = DOT_COUNT_ON_A_POSITIVE_LINE

        x = 0
        ys = (-d..d).map { |i| max.to_f * i.to_f / d.to_f }
        zs = ys.map { |y| f.calc(Vector[x, y]) }

        plot.data << Gnuplot::DataSet.new([ys, zs]) do |ds|
          ds.with = 'lines'
          ds.title = "value"
        end
      end
    end

    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title "#{f.label} fixed y"
        plot.xlabel 'x'
        plot.ylabel 'value'
        # plot.set 'format z "%1.1e"'

        d = DOT_COUNT_ON_A_POSITIVE_LINE
        
        y = 0
        xs = (-d..d).map { |i| max.to_f * i.to_f / d.to_f }
        zs = xs.map { |x| f.calc(Vector[x, y]) }

        plot.data << Gnuplot::DataSet.new([xs, zs]) do |ds|
          ds.with = 'lines'
          ds.title = "value"
        end
      end
    end
  end
end
