require "test_helper"

class SubmissionsChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts solution submissions" do
    solution = create :concept_solution
    submission_1 = create :submission, solution: solution, tests_status: :queued
    submission_2 = create :submission, solution: solution, tests_status: :passed

    assert_broadcast_on(
      SubmissionsChannel.broadcasting_for(solution.id),
      submissions: [SerializeSubmission.(submission_1), SerializeSubmission.(submission_2)]
    ) do
      SubmissionsChannel.broadcast!(solution)
    end
  end
end
