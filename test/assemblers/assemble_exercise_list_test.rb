require "test_helper"

class AssembleExerciseListTest < ActiveSupport::TestCase
  test "renders external user" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    expected = {
      exercises: SerializeExercises.([exercise], user_track: nil)
    }
    assert_equal expected, AssembleExerciseList.(nil, track, {})
  end

  test "renders for user" do
    user = create :user
    track = create :track
    exercise = create(:practice_exercise, track:)
    user_track = create(:user_track, user:, track:)

    expected = {
      exercises: SerializeExercises.([exercise], user_track:)
    }
    assert_equal expected, AssembleExerciseList.(user, track, {})
  end

  test "renders for user with solutions" do
    user = create :user
    track = create :track
    exercise_1 = create(:practice_exercise, track:)
    exercise_2 = create(:practice_exercise, track:)
    create(:practice_solution, exercise: exercise_1, user:)
    create :practice_solution, exercise: exercise_2 # Different user
    user_track = create(:user_track, user:, track:)

    expected = {
      exercises: SerializeExercises.([exercise_1, exercise_2], user_track:),
      solutions: SerializeSolutions.(user.solutions, user)
    }
    assert_equal expected, AssembleExerciseList.(user, track, { sideload: ['solutions'] })
  end

  test "proxies correctly" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)

    criteria = "foo"
    params = { sideload: ['solutions'], criteria: }

    exercises = mock
    serialized_exercises = mock
    serialized_solutions = mock

    Exercise::Search.expects(:call).with(user_track, criteria:).returns(exercises)
    SerializeExercises.expects(:call).with(exercises, user_track:).returns(serialized_exercises)
    SerializeSolutions.expects(:call).returns(serialized_solutions)

    expected = {
      exercises: serialized_exercises,
      solutions: serialized_solutions
    }
    assert_equal expected, AssembleExerciseList.(user, track, params)
  end
end
