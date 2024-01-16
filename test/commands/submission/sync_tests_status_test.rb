require 'test_helper'

class Submission::SyncTestsStatusTest < ActiveSupport::TestCase
  test "returns false with no test_run" do
    submission = create :submission
    refute Submission::SyncTestsStatus.(submission)
  end

  test "updates returns true with exceptioned" do
    submission = create :submission
    create(:submission_test_run, :timed_out, submission:)

    # Sanity
    assert_equal 'not_queued', submission.tests_status

    assert Submission::SyncTestsStatus.(submission)
    assert_equal 'exceptioned', submission.tests_status
  end

  test "updates and returns true with passed" do
    submission = create :submission
    create(:submission_test_run, submission:)

    # Sanity
    assert_equal 'not_queued', submission.tests_status

    assert Submission::SyncTestsStatus.(submission)
    assert_equal 'passed', submission.tests_status
  end

  test "updates and returns true with failed" do
    submission = create :submission
    create(:submission_test_run, :failed, submission:)

    # Sanity
    assert_equal 'not_queued', submission.tests_status

    assert Submission::SyncTestsStatus.(submission)
    assert_equal 'failed', submission.tests_status
  end

  test "updates and returns true with errored" do
    submission = create :submission
    create(:submission_test_run, :errored, submission:)

    # Sanity
    assert_equal 'not_queued', submission.tests_status

    assert Submission::SyncTestsStatus.(submission)
    assert_equal 'errored', submission.tests_status
  end

  test "uses latest test_run, even if a previous one is cached" do
    submission = create :submission, tests_status: :queued
    test_run_1 = create :submission_test_run, submission:, ops_status: 500
    assert_equal test_run_1, submission.test_run # Sanity

    Submission::SyncTestsStatus.(submission)
    assert_equal 'exceptioned', submission.tests_status

    create :submission_test_run, submission:, ops_status: 200
    # Sanity - Check that Rails has this cached to test_run_1, so that
    # we're actually testing the correct behaviour
    assert_equal test_run_1, submission.test_run

    Submission::SyncTestsStatus.(submission)
    assert_equal 'passed', submission.tests_status
  end
end
