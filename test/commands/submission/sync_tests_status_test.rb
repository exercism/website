require 'test_helper'

class Submission::SyncTestsStatusTest < ActiveSupport::TestCase
  test "returns false with no representation" do
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
end
