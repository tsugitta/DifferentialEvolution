require_relative './utility.rb'
require_relative './benchmark_function.rb'
require_relative './de.rb'

f = BenchmarkFunction::F1.new
de = DE::Basic.new(f)
de.exec
