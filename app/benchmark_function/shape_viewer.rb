class BenchmarkFunction::ShapeViewer
  DOT_COUNT_ON_A_POSITIVE_LINE = 100

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
            x = max.to_f * i / d
            y = max.to_f * j / d
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
end
