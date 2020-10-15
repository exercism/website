require "test_helper"

class Submission::TestRunsChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts test run" do
    submission = create :submission
    test_run = create :submission_test_run,
      submission: submission,
      ops_status: 403,
      raw_results: { message: nil }

    assert_broadcast_on(
      submission,
      test_run: {
        id: test_run.id,
        submission_uuid: test_run.submission.uuid,
        status: "ops_error",
        message: "Some error occurred",
        tests: nil
      }
    ) do
      Submission::TestRunsChannel.broadcast!(test_run)
    end
  end
end
