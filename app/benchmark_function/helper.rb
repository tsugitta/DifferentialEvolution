module BenchmarkFunction::Helper
  class << self
    def penalty(v)
      v.map { |e| [0, e.abs - 5].max**2 }.inject(:+)
    end

    def zeros(dim:)
      array = Array.new(dim, 0)
      Vector.elements(array, false)
    end

    def ones(dim:)
      array = Array.new(dim, 1)
      Vector.elements(array, false)
    end

    # Λ
    def lambda(dim:, alpha:)
      lambdas = Array.new(dim) do |i|
        alpha**(0.5 * i / (dim - 1))
      end

      elements = lambdas.map.with_index do |l, l_i|
        Array.new(dim) do |a_i|
          a_i == l_i ? l : 0
        end
      end

      Matrix.rows(elements, false)
    end

    # -1 and 1 appears with same possibility
    def one_plus_minus(dim:)
      array = Array.new(dim) { rand < 0.5 ? -1 : 1 }
      Vector.elements(array, false)
    end

    # T_asy
    def t_asy(vector, beta:)
      vector.map.with_index do |e, i|
        next e if e <= 0
        e**(1 + beta * (i / (vector.size - 1)) * Math.sqrt(e))
      end
    end

    # T_osz
    def t_osz(vector)
      if vector.class == Float
        is_one_dim = true
        vector = Vector.elements([vector], false)
      end

      res_vector = vector.map do |e|
        sin1 = Math.sin(c_1(e) * hat(e))
        sin2 = Math.sin(c_2(e) * hat(e))
        sign(e) * Math.exp(hat(e) + 0.049 * (sin1 + sin2))
      end

      if is_one_dim
        return res_vector.first
      end

      res_vector
    end

    # used in T_osz
    def hat(x)
      return 0 if x == 0
      Math.log(x.abs)
    end

    # used in T_osz
    def sign(x)
      return -1 if x < 0
      return 1 if x > 0
      0
    end

    # used in T_osz
    def c_1(x)
      return 10 if x > 0
      5.5
    end

    def c_2(x)
      return 7.9 if x > 0
      3.1
    end
  end
end
