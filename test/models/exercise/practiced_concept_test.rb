require "test_helper"

class Exercise::PracticedConceptTest < ActiveSupport::TestCase
  test "wired in correctly" do
    exercise = create :practice_exercise
    concept = create :track_concept
    practiced = create :exercise_practiced_concept,
      exercise: exercise,
      concept: concept

    assert_equal exercise, practiced.exercise
    assert_equal concept, practiced.concept
  end
end
