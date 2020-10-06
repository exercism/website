require 'test_helper'

class Exercise::PrerequisiteTest < ActiveSupport::TestCase
  test "wired in correctly" do
    exercise = create :concept_exercise
    concept = create :track_concept
    prereq = create :exercise_prerequisite,
      exercise: exercise,
      concept: concept

    assert_equal exercise, prereq.exercise
    assert_equal concept, prereq.concept
  end
end
