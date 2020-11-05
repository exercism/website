require 'test_helper'

module Git
  class ConceptTest < Minitest::Test
    def test_about
      concept = Concept.new(
        :csharp,
        :datetimes,
        "a9ce558b702ada6c5503888dc324668ac8aafc52",
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )

      assert concept.about.start_with?("A `DateTime` in C# is an immutable object")
    end

    def test_links
      concept = Concept.new(
        :csharp,
        :datetimes,
        "a9ce558b702ada6c5503888dc324668ac8aafc52",
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )

      assert_equal 3, concept.links.count
      assert_equal "https://docs.microsoft.com/en-us/dotnet/api/system.datetime?view=netcore-3.1", concept.links[0]["url"]  # rubocop:disable Layout/LineLength
      assert_equal "DateTime class", concept.links[0]["description"]
    end
  end
end
