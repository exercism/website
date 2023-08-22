require 'test_helper'

class Solution::SyncLatestIterationHeadTestsStatusTest < ActiveSupport::TestCase
  test "returns status correctly" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:)

    refute Solution::SyncLatestIterationHeadTestsStatus.(solution.reload)

    create :submission_test_run, submission:, git_important_files_hash: 'foobar'
    refute Solution::SyncLatestIterationHeadTestsStatus.(solution.reload)

    create(:submission_test_run, submission:)
    assert Solution::SyncLatestIterationHeadTestsStatus.(solution.reload)
  end

  test "updates and queues search index job but does not touch user_track solution run" do
    time = Time.current - 4.months

    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    create(:submission_test_run, submission:)
    user_track = create :user_track, user: submission.user, track: submission.track, last_touched_at: time

    Solution::AutoUpdateToLatestExerciseVersion.stubs(:call) # Stop an unrelated sync
    Solution::SyncToSearchIndex.expects(:defer).with(submission.solution)

    assert Solution::SyncLatestIterationHeadTestsStatus.(solution)

    assert_equal time.to_i, user_track.reload.last_touched_at.to_i
    assert_equal :passed, solution.latest_iteration_head_tests_status
  end

  test "auto updates git_sha if passes" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    create(:submission_test_run, submission:)

    solution.update!(git_sha: "foobar")

    # Sanity check
    refute_equal exercise.git_sha, solution.reload.git_sha

    Solution::SyncLatestIterationHeadTestsStatus.(solution)

    assert_equal exercise.git_sha, solution.reload.git_sha
  end
end
