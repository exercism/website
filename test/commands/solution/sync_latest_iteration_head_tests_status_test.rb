require 'test_helper'

class Submission::TestRun::ProcessTest < ActiveSupport::TestCase
  test "returns status correctly" do
    solution = create :practice_solution
    submission = create :submission, solution: solution
    create :iteration, submission: submission

    refute Solution::SyncLatestIterationHeadTestsStatus.(solution.reload)

    create :submission_test_run, submission: submission, git_important_files_hash: 'foobar'
    refute Solution::SyncLatestIterationHeadTestsStatus.(solution.reload)

    create :submission_test_run, submission: submission
    assert Solution::SyncLatestIterationHeadTestsStatus.(solution.reload)
  end

  test "updates and queues search index job but does not touch user_track solution run" do
    time = Time.current - 4.months

    solution = create :practice_solution
    submission = create :submission, solution: solution
    create :iteration, submission: submission
    create :submission_test_run, submission: submission
    user_track = create :user_track, user: submission.user, track: submission.track, last_touched_at: time

    SyncSolutionToSearchIndexJob.expects(:perform_later).with(submission.solution)

    assert Solution::SyncLatestIterationHeadTestsStatus.(solution)

    assert_equal time.to_i, user_track.reload.last_touched_at.to_i
    assert_equal :passed, solution.latest_iteration_head_tests_status
  end
end
