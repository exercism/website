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
    assert concept.about.starts_with?("A `DateTime` in C#")
  end

  test "links" do
    concept = create :track_concept, :with_git_data
    links = concept.links

    assert_equal 3, links.count
    assert_equal "https://docs.microsoft.com/en-us/dotnet/api/system.datetime?view=netcore-3.1", links.first["url"]  # rubocop:disable Layout/LineLength
    assert_equal "DateTime class", links.first["description"]
  end

  test "concept_exercises" do
    track = create :track
    concept = create :track_concept, track: track

    ce_1 = create :concept_exercise, :random_slug, track: track
    ce_1.taught_concepts << concept
    ce_2 = create :concept_exercise, :random_slug, track: track
    ce_2.taught_concepts << create(:track_concept, track: track)

    pe_1 = create :practice_exercise, :random_slug, track: track
    pe_1.prerequisites << concept
    pe_2 = create :practice_exercise, :random_slug, track: track
    pe_2.prerequisites << concept
    pe_3 = create :practice_exercise, :random_slug, track: track
    pe_3.prerequisites << create(:track_concept, track: track)

    assert_equal [ce_1], concept.concept_exercises
    assert_equal [pe_1, pe_2], concept.practice_exercises
  end
end
