require 'test_helper'

class Solution
  class AutoUpdateToLatestExerciseVersionTest < ActiveSupport::TestCase
    test "calls update if appropriate" do
      solution = create :practice_solution, git_sha: "foobar", latest_iteration_head_tests_status: :passed

      UpdateToLatestExerciseVersion.expects(:call).with(solution)

      AutoUpdateToLatestExerciseVersion.(solution)
    end

    test "doesn't call update if git_sha is already the same" do
      solution = create :practice_solution, latest_iteration_head_tests_status: :passed

      UpdateToLatestExerciseVersion.expects(:call).never

      AutoUpdateToLatestExerciseVersion.(solution)
    end

    test "doesn't call update if head tests status is failed" do
      solution = create :practice_solution, latest_iteration_head_tests_status: :failed

      UpdateToLatestExerciseVersion.expects(:call).never

      AutoUpdateToLatestExerciseVersion.(solution)
    end
  end
end
