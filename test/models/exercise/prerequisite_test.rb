require 'test_helper'

class Exercise::PrerequisiteTest < ActiveSupport::TestCase
  test "wired in correctly" do
    exercise = create :concept_exercise
    concept = create :concept
    prereq = create(:exercise_prerequisite,
      exercise:,
      concept:)

    assert_equal exercise, prereq.exercise
    assert_equal concept, prereq.concept
  end
end
