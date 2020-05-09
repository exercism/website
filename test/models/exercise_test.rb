require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test "scope :without_prerequisites" do
    exercise1 = create :concept_exercise
    exercise2 = create :concept_exercise

    assert_equal [exercise1, exercise2], Exercise.without_prerequisites

    create :exercise_prerequisite, exercise: exercise1
    assert_equal [exercise2], Exercise.without_prerequisites
  end
end
