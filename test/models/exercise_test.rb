require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test "to_slug" do
    exercise = create :concept_exercise
    assert_equal exercise.slug, exercise.to_param
  end

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

  test "prerequisite_exercises" do
    strings = create :track_concept
    bools = create :track_concept
    conditionals = create :track_concept

    exercise = create :practice_exercise
    exercise.prerequisites << strings
    exercise.prerequisites << bools

    pre_ex_1 = create(:concept_exercise)
    pre_ex_1.taught_concepts << strings

    pre_ex_2 = create(:concept_exercise)
    pre_ex_2.taught_concepts << bools

    pre_ex_3 = create(:concept_exercise)
    pre_ex_3.taught_concepts << conditionals

    assert_equal [pre_ex_1, pre_ex_2], exercise.prerequisite_exercises
  end
end
