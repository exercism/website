require "test_helper"

class IterationChannelTest < ActionCable::Channel::TestCase
  test ".broadcast! broadcasts iteration" do
    solution = create :concept_solution
    iteration = create :iteration, solution: solution

    assert_broadcast_on(
      'iteration',
      iteration: {
        id: iteration.id,
        track: "Ruby",
        exercise: "Bob",
        testsStatus: "pending",
        representationStatus: "pending",
        analysisStatus: "pending"
      }
    ) do
      IterationChannel.broadcast!(iteration)
    end
  end
end
