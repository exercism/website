require "test_helper"

class Solution::UpdateLatestIterationHeadTestsStatusTest < ActiveSupport::TestCase
  test "updates latest iteration head tests status when status is different" do
    new_status = :passed
    solution = create(:practice_solution, latest_iteration_head_tests_status: :queued)

    Solution::UpdateLatestIterationHeadTestsStatus.(solution, new_status)

    assert_equal new_status, solution.latest_iteration_head_tests_status
  end

  test "sync to search index when status is different" do
    solution = create :practice_solution, latest_iteration_head_tests_status: :queued

    Solution::SyncToSearchIndex.expects(:defer).with(solution).once

    Solution::UpdateLatestIterationHeadTestsStatus.(solution, :passed)
  end

  test "does not update solution when status is the same" do
    updated_at = Time.current - 1.week
    solution = create(:practice_solution, updated_at:)

    Solution::UpdateLatestIterationHeadTestsStatus.(solution, solution.latest_iteration_head_tests_status)

    assert_equal updated_at, solution.updated_at
  end

  test "does not sync to search index when status is the same" do
    solution = create :practice_solution

    Solution::SyncToSearchIndex.expects(:defer).never

    Solution::UpdateLatestIterationHeadTestsStatus.(solution, solution.latest_iteration_head_tests_status)
  end
end
