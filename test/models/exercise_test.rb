require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test "prerequisites works correctly" do
    exercise = create :concept_exercise

    concept = create :track_concept
    create :track_concept

    exercise.prerequisites << concept

    assert_equal [concept], exercise.reload.prerequisites
  end

  test "scope :without_prerequisites" do
    exercise_1 = create :concept_exercise
    exercise_2 = create :concept_exercise

    assert_equal [exercise_1, exercise_2], Exercise.without_prerequisites

    create :exercise_prerequisite, exercise: exercise_1
    assert_equal [exercise_2], Exercise.without_prerequisites
  end
end
