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
        testsStatus: "pending",
        representationStatus: "pending",
        analysisStatus: "pending"
      }
    ) do
      SubmissionChannel.broadcast!(submission)
    end
  end
end
