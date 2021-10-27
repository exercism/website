class Solution
  class PublishIteration
    include Mandate

    initialize_with :solution, :iteration_idx

    def call
      solution.update!(published_iteration: iteration, num_loc: iteration.num_loc)
    end

    private
    memoize
    def iteration
      solution.iterations.find_by(idx: iteration_idx)
    end
  end
end
