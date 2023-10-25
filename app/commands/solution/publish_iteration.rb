class Solution::PublishIteration
  include Mandate

  initialize_with :solution, :iteration_idx

  def call
    solution.update!(published_iteration: iteration)

    Solution::UpdateTags.(solution)
    Solution::UpdatePublishedExerciseRepresentation.(solution)
    Solution::UpdateSnippet.(solution)
    Solution::UpdateNumLoc.(solution)

    # Calculate the solution latest published iteration's num_loc
    # when that has not yet been done
    return unless latest_published_iteration && latest_published_iteration.num_loc.nil?

    Iteration::CalculateLinesOfCode.defer(latest_published_iteration)
  end

  private
  memoize
  def iteration
    return nil unless iteration_idx

    solution.iterations.find_by(idx: iteration_idx)
  end

  memoize
  def latest_published_iteration = iteration || solution.latest_published_iteration
end
