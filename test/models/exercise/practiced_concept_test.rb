require "test_helper"

class Exercise::PracticedConceptTest < ActiveSupport::TestCase
  test "wired in correctly" do
    exercise = create :practice_exercise
    concept = create :concept
    practiced = create(:exercise_practiced_concept,
      exercise:,
      concept:)

    assert_equal exercise, practiced.exercise
    assert_equal concept, practiced.concept
  end
end
