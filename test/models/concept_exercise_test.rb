require 'test_helper'

class ConceptExerciseTest < ActiveSupport::TestCase
  test "taught_concepts works correctly" do
    exercise = create :concept_exercise
    concept = create :track_concept
    create :track_concept

    exercise.taught_concepts << concept

    assert_equal [concept], exercise.reload.taught_concepts
  end
end
