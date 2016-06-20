require_relative './utility.rb'
require_relative './benchmark.rb'
require_relative './de.rb'

f = Benchmark::F1.new
de = DE::Basic.new(f)
de.exec
