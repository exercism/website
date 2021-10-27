class Solution
  class PublishIteration
    include Mandate

    initialize_with :solution, :iteration_idx

    def call
      solution.update!(published_iteration: iteration, num_loc: num_loc)
    end

    private
    memoize
    def iteration
      solution.iterations.find_by(idx: iteration_idx)
    end

    def num_loc
      return solution.iterations.last.num_loc if iteration_idx.nil?

      iteration.num_loc
    end
  end
end
