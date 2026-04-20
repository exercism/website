class Solution::PublishIteration
  include Mandate

  initialize_with :solution, :iteration_idx, invalidate: true

  def call
    solution.update!(published_iteration: iteration)

    Solution::UpdateTags.defer(solution)
    Solution::UpdatePublishedExerciseRepresentation.defer(solution)
    Solution::UpdateSnippet.defer(solution)
    Solution::UpdateNumLoc.defer(solution)
  end

  private
  memoize
  def iteration
    return nil unless iteration_idx

    solution.iterations.find_by(idx: iteration_idx)
  end
end
