require "test_helper"

class Submission::TestRunsChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts test run" do
    submission = create :submission
    test_run = create :submission_test_run,
      submission:,
      ops_status: 403,
      raw_results: { message: nil }

    assert_broadcast_on(
      submission.id,
      test_run: SerializeSubmissionTestRun.(test_run)
    ) do
      Submission::TestRunsChannel.broadcast!(test_run)
    end
  end
end
