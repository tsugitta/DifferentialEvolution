class DiffOfAllParametersPlotter
  def initialize(vectors:, archived_vectors:, title:, mutation_method:, crossover_method:, p_to_use_current_to_pbest_mutation:, f:)
    @vectors = vectors
    @archived_vectors = archived_vectors
    @title = title
    @mutation_method = mutation_method
    @crossover_method = crossover_method
    @p_to_use_current_to_pbest_mutation = p_to_use_current_to_pbest_mutation
    @f = f

    @parameters = []
    @median_parameters = []
    @one_sigma_parameters = []
  end

  def exec
    puts 'DiffOfAllParametersPlotter executing..'
    create_parameters_with_diff
    show
  end

  def create_parameters_with_diff
    0.step(1, 0.05).each do |f|
      f = f.round(2)
      0.step(1, 0.02).each do |c|
        c = c.round(2)
        print "\rf: #{f}, c: #{c}"

        parameters_fixed_c_f = []
        1.times do |i|
          ps = Array.new(@vectors.size) do
            Parameter.new(magnification_rate: f, use_mutated_component_rate: c)
          end

          assign_diff_of_evaluated_value(ps)
          parameters_fixed_c_f += ps
        end

        update_statistic_parameters(parameters: parameters_fixed_c_f, f: f, c: c)

        @parameters += parameters_fixed_c_f
      end
    end
  end

  def show
    title_suffix = ['median', 'one sigma']

    [@median_parameters, @one_sigma_parameters].each.with_index do |ps, i|
      Gnuplot.open do |gp|
        Gnuplot::SPlot.new(gp) do |plot|
          plot.title "#{@title} #{title_suffix[i]}"

          plot.xlabel 'F'
          plot.ylabel 'C'

          # plot.set 'key outside'

          plot.set "dgrid3d 30,30"
          plot.set "hidden3d"
          plot.set "style fill  transparent solid 0.60 border"

          plot.set "view map"
          plot.set 'contour'
          plot.set 'cntrparam levels auto 30'
          plot.set "palette defined ( 0 '#000090',1 '#000fff',2 '#0090ff',3 '#0fffee',4 '#90ff70',5 '#ffee00',6 '#ff7000',7 '#ee0000',8 '#7f0000')"

          plot.data << Gnuplot::DataSet.new([ps.map(&:magnification_rate), ps.map(&:use_mutated_component_rate), ps.map(&:calculated_value_diff)]) do |ds|
            ds.with = "pm3d"
            ds.notitle
          end
        end
      end
    end
  end

  def assign_diff_of_evaluated_value(parameters)
    raise 'parameters\' size must be same as vectors\' one' unless parameters.size == @vectors.size

    mutated = mutated_vectors(parameters: parameters)
    children = crossovered_children(parameters: parameters, mutated_vectors: mutated)

    parameters.each.with_index do |p, i|
      p.calculated_value_diff = children[i].calculate_with(@f) - @vectors[i].calculate_with(@f)
    end
  end

  private

  def update_statistic_parameters(parameters:, f:, c:)
    diffs = parameters.map(&:calculated_value_diff)

    median_p = Parameter.new \
      magnification_rate: f,
      use_mutated_component_rate: c,
      calculated_value_diff: diffs.median

    one_sigma_p = Parameter.new \
      magnification_rate: f,
      use_mutated_component_rate: c,
      calculated_value_diff: diffs.mean - diffs.sd

    @median_parameters << median_p
    @one_sigma_parameters << one_sigma_p
  end

  def mutated_vectors(parameters:)
    DE::MutatedVectorCreator.new(
      @vectors,
      parameters: parameters,
      mutation_method: @mutation_method,
      p: @p_to_use_current_to_pbest_mutation,
      f: @f,
      archived_vectors: @archived_vectors
    ).create
  end

  def crossovered_children(parameters:, mutated_vectors:)
    DE::CrossoverExecutor.new(
      parent_vectors: @vectors,
      mutated_vectors: mutated_vectors,
      parameters: parameters,
      crossover_method: @crossover_method
    ).create_children
  end
end
