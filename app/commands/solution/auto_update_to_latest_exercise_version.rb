class Solution
  class AutoUpdateToLatestExerciseVersion
    include Mandate

    initialize_with :solution

    def call
      return if solution.git_sha == solution.exercise.git_sha
      return unless solution.latest_iteration_head_tests_status == :passed

      Solution::UpdateToLatestExerciseVersion.(solution)
    end
  end
end
