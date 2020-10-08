require "test_helper"

class ConceptExercise::CompleteTest < ActiveSupport::TestCase
  test "raises unless solution exists" do
    assert_raises SolutionNotFoundError do
      ConceptExercise::Complete.(create(:user), create(:concept_exercise))
    end
  end

  test "sets solution as completed" do
    exercise = create :concept_exercise

    user = create :user
    create :user_track, user: user, track: exercise.track
    solution = create :concept_solution, user: user, exercise: exercise

    ConceptExercise::Complete.(user, exercise)

    assert solution.reload.completed?
  end

  test "sets concepts as learnt" do
    concept = create :track_concept
    exercise = create :concept_exercise
    exercise.taught_concepts << concept

    user = create :user
    ut = create :user_track, user: user, track: exercise.track
    create :concept_solution, user: user, exercise: exercise

    ConceptExercise::Complete.(user, exercise)

    assert ut.learnt_concept?(concept)
  end
end
