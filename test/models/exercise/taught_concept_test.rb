require "test_helper"

class Exercise::TaughtConceptTest < ActiveSupport::TestCase
  test "wired in correctly" do
    exercise = create :concept_exercise
    concept = create :concept
    taught_concept = create(:exercise_taught_concept,
      exercise:,
      concept:)

    assert_equal exercise, taught_concept.exercise
    assert_equal concept, taught_concept.concept
  end
end
