require 'test_helper'

class ConceptTest < ActiveSupport::TestCase
  test "scope :not_taught" do
    concept_1 = create :concept
    concept_2 = create :concept

    assert_equal [concept_1, concept_2], Concept.not_taught

    create :exercise_taught_concept, concept: concept_1
    assert_equal [concept_2], Concept.not_taught
  end

  test "about" do
    concept = create :concept, :with_git_data

    expected = "A String object holds and manipulates an arbitrary sequence of bytes, typically representing characters. String objects may be created using ::new or as literals." # rubocop:disable Layout/LineLength
    assert_equal expected, concept.about
  end

  test "links" do
    concept = create :concept, :with_git_data
    links = concept.links

    expected = [
      {
        url: "https://ruby-doc.org/core-3.0.0/String.html",
        description: "String class"
      },
      {
        url: "https://www.geeksforgeeks.org/ruby-string-basics/",
        description: "String basics"
      }
    ]
    assert_equal expected, links.map(&:to_h)
  end

  test "concept_exercises" do
    concept = create :concept
    exercise = create :concept_exercise
    create(:exercise_taught_concept, concept:, exercise:)

    # Create a random different one
    create :exercise_taught_concept

    assert_equal [exercise], concept.concept_exercises
  end

  test "practice_exercises" do
    concept = create :concept
    exercise = create :practice_exercise
    create(:exercise_practiced_concept, concept:, exercise:)

    # Create a random different one
    create :exercise_taught_concept

    assert_equal [exercise], concept.practice_exercises
  end

  test "unlocked_exercises" do
    concept = create :concept
    exercise = create :practice_exercise
    create(:exercise_prerequisite, concept:, exercise:)

    # Create a random different one
    create :exercise_taught_concept

    assert_equal [exercise], concept.unlocked_exercises
  end

  test "can be deleted" do
    track = create :track

    concept = create(:concept, track:)
    ce = create(:concept_exercise, track:)
    ce.prerequisites << concept
    ce.taught_concepts << concept
    pe = create(:concept_exercise, track:)
    pe.prerequisites << concept

    concept.destroy
    refute Concept.where(id: concept.id).exists?
  end

  test "deletes associated site updates" do
    track = create :track
    concept = create(:concept, track:)

    site_update = create :new_concept_site_update, params: { concept: }
    assert_equal concept, site_update.concept # Sanity

    concept.destroy

    refute Concept.where(id: concept.id).exists?
    refute SiteUpdate.where(id: site_update.id).exists?
  end
end
