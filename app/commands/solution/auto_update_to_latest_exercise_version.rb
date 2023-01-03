class Solution::AutoUpdateToLatestExerciseVersion
  include Mandate

  initialize_with :solution

  def call
    return if solution.git_sha == solution.exercise.git_sha
    return unless solution.latest_iteration_head_tests_status == :passed
    return unless solution.user.preferences.auto_update_exercises?

    Solution::UpdateToLatestExerciseVersion.(solution)
  end
end
