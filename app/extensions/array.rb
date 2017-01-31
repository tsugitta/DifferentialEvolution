class Array
  def mean
    sum.to_f / size
  end

  def var
    m = mean
    reduce(0) { |a, b| a + (b - m)**2 } / (size - 1)
  end

  def sd
    Math.sqrt(var)
  end

  def median
    sorted = self.sort
    size % 2 == 0 ? sorted[size / 2 - 1, 2].inject(:+) / 2.0 : sorted[size / 2]
  end

  def one_fourth
    sorted = self.sort
    prev = sorted.select { |e| e < median }
    return first if prev.empty?
    prev.median
  end
end
