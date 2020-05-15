require "test_helper"

class StartExerciseTest < ActiveSupport::TestCase
  test "raises unless exercise is available" do
    ex = create :concept_exercise
    ut = create :user_track
    ut.expects(:exercise_available?).with(ex).returns(false)

    assert_raises ExerciseUnavailableError do
      User::StartExercise.(ut, ex)
    end
  end

  test "creates concept_solution" do
    ex = create :concept_exercise
    ut = create :user_track
    ut.expects(:exercise_available?).with(ex).returns(true)

    solution = User::StartExercise.(ut, ex)
    assert solution.is_a?(ConceptSolution)
    assert_equal ut.user, solution.user
    assert_equal ex, solution.exercise
  end

  test "creates practice_solution" do
    ex = create :practice_exercise
    ut = create :user_track
    ut.expects(:exercise_available?).with(ex).returns(true)

    solution = User::StartExercise.(ut, ex)
    assert solution.is_a?(PracticeSolution)
    assert_equal ut.user, solution.user
    assert_equal ex, solution.exercise
  end

  test "duplicated exercises are a noop that return solution" do
    user = create :user
    ex = create :concept_exercise
    solution = create :concept_solution, user: user, exercise: ex
    ut = create :user_track, user: user
    ut.expects(:exercise_available?).with(ex).returns(true)

    assert_equal solution, User::StartExercise.(ut, ex)
  end
end

