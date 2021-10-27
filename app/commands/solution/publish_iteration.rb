class Solution
  class PublishIteration
    include Mandate

    initialize_with :solution, :iteration_idx

    def call
      solution.update!(published_iteration: published_iteration)
    end

    private
    def published_iteration
      solution.iterations.find_by(idx: iteration_idx)
    end
  end
end
