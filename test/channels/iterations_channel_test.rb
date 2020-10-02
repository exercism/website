require "test_helper"

class IterationsChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts solution iterations" do
    solution = create :concept_solution
    iteration_1 = create :iteration, solution: solution, tests_status: :pending
    iteration_2 = create :iteration, solution: solution, tests_status: :passed

    assert_broadcast_on(
      IterationsChannel.broadcasting_for(solution),
      iterations: [{ id: iteration_1.id, testsStatus: "pending" }, { id: iteration_2.id, testsStatus: "passed"}]
    ) do
      IterationsChannel.broadcast!(solution)
    end
  end
end
