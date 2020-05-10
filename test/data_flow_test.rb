require "test_helper"

class DataFlowTest < ActiveSupport::TestCase
  test "the flow" do
    # TODO - Destub these
    track = create :track
    concept_exercise_basics = create :concept_exercise, track: track, slug: 'basics', prerequisites: []
    concept_exercise_strings = create :concept_exercise, track: track, slug: 'strings', prerequisites: []
    create :exercise_prerequisite, exercise: concept_exercise_strings

    # TODO - Destub these
    user = create :user

    # User joins the track
    # Check its retrieved correctly.
    ut = User::JoinTrack.call(user, track)
    assert_equal ut, UserTrack.for!(user, track)

    # Check we only have basics to start with
    assert_equal [concept_exercise_basics], ut.available_concept_exercises

    # Start the exercise and get a solution
    basics_solution = UserTrack::StartExercise.(ut, concept_exercise_basics)
  end
end
