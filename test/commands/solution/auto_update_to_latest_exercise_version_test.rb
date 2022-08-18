require 'test_helper'

class Solution
  class AutoUpdateToLatestExerciseVersionTest < ActiveSupport::TestCase
    test "calls update if appropriate" do
      solution = create_solution

      UpdateToLatestExerciseVersion.expects(:call).with(solution)

      AutoUpdateToLatestExerciseVersion.(solution)
    end

    test "doesn't call update if git_sha is already the same" do
      solution = create_solution(git_sha: "HEAD")

      UpdateToLatestExerciseVersion.expects(:call).never

      AutoUpdateToLatestExerciseVersion.(solution)
    end

    test "doesn't call update if head tests status is failed" do
      solution = create_solution(latest_iteration_head_tests_status: :failed)

      UpdateToLatestExerciseVersion.expects(:call).never

      AutoUpdateToLatestExerciseVersion.(solution)
    end

    test "doesn't call update if user has setting disabled" do
      user = create :user
      user.preferences.update!(auto_update_exercises: false)
      solution = create_solution(user:)

      UpdateToLatestExerciseVersion.expects(:call).never

      AutoUpdateToLatestExerciseVersion.(solution)
    end

    def create_solution(params = {})
      create :practice_solution,
        {
          git_sha: "foobar",
          latest_iteration_head_tests_status: :passed
        }.merge(params)
    end
  end
end
