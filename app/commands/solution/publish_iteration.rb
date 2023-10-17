class Solution::PublishIteration
  include Mandate

  initialize_with :solution, :iteration_idx

  def call
    solution.update!(published_iteration: iteration)

    Solution::UpdateTags.(solution)
    Solution::UpdatePublishedExerciseRepresentation.(solution)
    Solution::UpdateSnippet.(solution)
    Solution::UpdateNumLoc.(solution)
  end

  private
  memoize
  def iteration
    return nil unless iteration_idx

    solution.iterations.find_by(idx: iteration_idx)
  end

  def num_loc
    iteration ? iteration.num_loc : solution.latest_iteration&.num_loc
  end
end
