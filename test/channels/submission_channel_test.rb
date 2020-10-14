require "test_helper"

class SubmissionChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts submission" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    assert_broadcast_on(
      'submission',
      submission: {
        id: submission.id,
        track: "Ruby",
        exercise: "Bob",
        testsStatus: "not_queued",
        representationStatus: "not_queued",
        analysisStatus: "not_queued"
      }
    ) do
      SubmissionChannel.broadcast!(submission)
    end
  end
end
