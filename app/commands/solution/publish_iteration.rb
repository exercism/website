class Solution
  class PublishIteration
    include Mandate

    initialize_with :solution, :iteration_idx

    def call
      solution.update!(published_iteration: iteration)

      CalculateLinesOfCodeJob.perform_later(iteration)
    end

    private
    memoize
    def iteration
      solution.iterations.find_by(idx: iteration_idx)
    end
  end
end
