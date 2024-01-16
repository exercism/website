require "test_helper"

class Solution::UpdatePublishedIterationHeadTestsStatusTest < ActiveSupport::TestCase
  test "updates published iteration head tests status when status is different" do
    new_status = :passed
    solution = create(:practice_solution, published_iteration_head_tests_status: :queued)

    Solution::UpdatePublishedIterationHeadTestsStatus.(solution, new_status)

    assert_equal new_status, solution.published_iteration_head_tests_status
  end

  test "sync to search index when status is different" do
    solution = create :practice_solution, published_iteration_head_tests_status: :queued

    Solution::SyncToSearchIndex.expects(:defer).with(solution).once

    Solution::UpdatePublishedIterationHeadTestsStatus.(solution, :passed)
  end

  test "updates solution tags when status is different" do
    solution = create :practice_solution, published_iteration_head_tests_status: :queued

    Solution::UpdateTags.expects(:defer).with(solution).once

    Solution::UpdatePublishedIterationHeadTestsStatus.(solution, :passed)
  end

  test "does not update solution when status is the same" do
    updated_at = Time.current - 1.week
    solution = create(:practice_solution, updated_at:)

    Solution::UpdatePublishedIterationHeadTestsStatus.(solution, solution.published_iteration_head_tests_status)

    assert_equal updated_at, solution.updated_at
  end

  test "does not sync to search index when status is the same" do
    solution = create :practice_solution

    Solution::SyncToSearchIndex.expects(:defer).never

    Solution::UpdatePublishedIterationHeadTestsStatus.(solution, solution.published_iteration_head_tests_status)
  end

  test "does not update solution tags when status is the same" do
    solution = create :practice_solution

    Solution::UpdateTags.expects(:defer).never

    Solution::UpdatePublishedIterationHeadTestsStatus.(solution, solution.published_iteration_head_tests_status)
  end
end
