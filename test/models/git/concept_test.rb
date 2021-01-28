require 'test_helper'

module Git
  class ConceptTest < ActiveSupport::TestCase
    test "about" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      expected = "A String object holds and manipulates an arbitrary sequence of bytes, typically representing characters. String objects may be created using ::new or as literals.\n" # rubocop:disable Layout/LineLength
      assert_equal expected, concept.about
    end

    test "introduction" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      expected = "A String object holds and manipulates an arbitrary sequence of bytes, typically representing characters.\n"
      assert_equal expected, concept.introduction
    end

    test "links" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

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
      assert_equal expected, concept.links.map(&:to_h)
    end
  end
end
