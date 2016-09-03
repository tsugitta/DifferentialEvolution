# refer to http://www.sat.t.u-tokyo.ac.jp/~omi/random_variables_generation.html
class Random
  class << self
    include Math

    # Using Box-Muller's method
    def rand_following_normal(mu, sigma)
      mu + sigma * (sqrt(-2 * log(rand)) * sin(2 * PI * rand))
    end

    def rand_following_normal_from_0_to_1(mu, sigma)
      rand_n = rand_following_normal(mu, sigma)

      rand_n = 1 if rand_n > 1
      rand_n = 0 if rand < 0

      rand_n
    end

    def rand_following_cauchy(mu, gamma)
      mu + gamma * tan(PI * (rand - 0.5))
    end

    def rand_following_cauchy_from_0_to_1(mu, gamma)
      rand_c = rand_following_cauchy(mu, gamma)

      while rand_c < 0
        rand_c = rand_following_cauchy(mu, gamma)
      end

      rand_c = 1 if rand_c > 1

      rand_c
    end
  end
end
