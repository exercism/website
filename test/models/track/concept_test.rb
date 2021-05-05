require 'test_helper'

class Track::ConceptTest < ActiveSupport::TestCase
  test "scope :not_taught" do
    concept_1 = create :track_concept
    concept_2 = create :track_concept

    assert_equal [concept_1, concept_2], Track::Concept.not_taught

    create :exercise_taught_concept, concept: concept_1
    assert_equal [concept_2], Track::Concept.not_taught
  end

  test "about" do
    concept = create :track_concept, :with_git_data

    expected = "A String object holds and manipulates an arbitrary sequence of bytes, typically representing characters. String objects may be created using ::new or as literals.\n" # rubocop:disable Layout/LineLength
    assert_equal expected, concept.about
  end

  test "links" do
    concept = create :track_concept, :with_git_data
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
    concept = create :track_concept
    exercise = create :concept_exercise
    create :exercise_taught_concept, concept: concept, exercise: exercise

    # Create a random different one
    create :exercise_taught_concept

    assert_equal [exercise], concept.concept_exercises
  end

  test "practice_exercises" do
    concept = create :track_concept
    exercise = create :practice_exercise
    create :exercise_practiced_concept, concept: concept, exercise: exercise

    # Create a random different one
    create :exercise_taught_concept

    assert_equal [exercise], concept.practice_exercises
  end

  test "unlocked_exercises" do
    concept = create :track_concept
    exercise = create :practice_exercise
    create :exercise_prerequisite, concept: concept, exercise: exercise

    # Create a random different one
    create :exercise_taught_concept

    assert_equal [exercise], concept.unlocked_exercises
  end

  test "can be deleted" do
    track = create :track

    concept = create :track_concept, track: track
    ce = create :concept_exercise, track: track
    ce.prerequisites << concept
    ce.taught_concepts << concept
    pe = create :concept_exercise, track: track
    pe.prerequisites << concept

    concept.destroy
    refute Track::Concept.where(id: concept.id).exists?
  end
end
