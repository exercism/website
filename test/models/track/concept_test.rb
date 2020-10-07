require 'test_helper'

class Track::ConceptTest < ActiveSupport::TestCase
  test "scope :not_taught" do
    concept_1 = create :track_concept
    concept_2 = create :track_concept

    assert_equal [concept_1, concept_2], Track::Concept.not_taught

    create :exercise_taught_concept, concept: concept_1
    assert_equal [concept_2], Track::Concept.not_taught
  end
end
