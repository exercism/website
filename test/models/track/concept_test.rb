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
end
