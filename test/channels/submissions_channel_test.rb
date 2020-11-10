require "test_helper"

class SubmissionsChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts solution submissions" do
    solution = create :concept_solution
    submission_1 = create :submission, solution: solution, tests_status: :queued
    submission_2 = create :submission, solution: solution, tests_status: :passed

    assert_broadcast_on(
      SubmissionsChannel.broadcasting_for(solution.id),
      submissions: [{ id: submission_1.id, testsStatus: "queued" }, { id: submission_2.id, testsStatus: "passed" }]
    ) do
      SubmissionsChannel.broadcast!(solution)
    end
  end
end
