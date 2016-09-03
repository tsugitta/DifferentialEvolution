class MathCalculator
  class << self
    def arithmetic_mean(values)
      values.inject(:+) / values.size
    end

    def lehmer_mean(values)
      sum = 0.0
      square_sum = 0.0

      values.each do |value|
        sum += value
        square_sum += value ** 2
      end

      return 0 if sum == 0
      square_sum / sum
    end
  end
end
