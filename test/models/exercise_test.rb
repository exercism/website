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

  test "scope :sorted" do
    exercise_1 = create :practice_exercise, position: 0
    exercise_2 = create :concept_exercise, position: 1
    exercise_3 = create :concept_exercise, position: 2
    exercise_4 = create :practice_exercise, position: 3

    assert_equal [exercise_1, exercise_2, exercise_3, exercise_4], Exercise.sorted
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

  test "difficulty_description" do
    {
      easy: [1, 2, 3],
      medium: [4, 5, 6, 7],
      hard: [8, 9, 10]
    }.each do |desc, values|
      values.each do |val|
        assert_equal desc.to_s, create(:practice_exercise, difficulty: val).difficulty_description
      end
    end
  end

  test "icon_url for exercise without custom icon" do
    exercise = create :practice_exercise, slug: 'bob'
    assert_equal "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/exercises/bob.svg", exercise.icon_url
  end

  test "icon_url for exercise with custom icon" do
    exercise = create :practice_exercise, slug: 'isogram'
    assert_equal "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/exercises/iso.svg", exercise.icon_url
  end
end
