require 'test_helper'

class Solution::SyncPublishedIterationHeadTestsStatusTest < ActiveSupport::TestCase
  test "returns status correctly" do
    solution = create :practice_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:)

    refute Solution::SyncPublishedIterationHeadTestsStatus.(solution.reload)

    create :submission_test_run, submission:, git_important_files_hash: 'foobar'
    refute Solution::SyncPublishedIterationHeadTestsStatus.(solution.reload)

    create(:submission_test_run, submission:)
    assert Solution::SyncPublishedIterationHeadTestsStatus.(solution.reload)
  end

  test "updates and queues search index job but does not touch user_track solution run" do
    time = Time.current - 4.months

    solution = create :practice_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    create(:submission_test_run, submission:)
    user_track = create :user_track, user: submission.user, track: submission.track, last_touched_at: time

    Solution::SyncToSearchIndex.expects(:defer).with(submission.solution)

    assert Solution::SyncPublishedIterationHeadTestsStatus.(solution)

    assert_equal time.to_i, user_track.reload.last_touched_at.to_i
    assert_equal :passed, solution.published_iteration_head_tests_status
  end
end
