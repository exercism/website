class Solution::PublishIteration
  include Mandate

  initialize_with :solution, :iteration_idx

  def call
    solution.update!(published_iteration: iteration)

    Solution::UpdateTags.(solution)
    Solution::UpdatePublishedExerciseRepresentation.(solution)
    Solution::UpdateSnippet.(solution)
    Solution::UpdateNumLoc.(solution)
    Infrastructure::InvalidateCloudfrontItems.(
      :website,
      [Exercism::Routes.track_exercise_solution_path(track, exercise, user, format: :jpg)]
    )
  end

  private
  delegate :user, :exercise, :track, to: :solution

  memoize
  def iteration
    return nil unless iteration_idx

    solution.iterations.find_by(idx: iteration_idx)
  end
end
