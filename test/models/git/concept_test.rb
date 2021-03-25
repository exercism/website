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

    test "about file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('about.md', concept.about_filepath)
    end

    test "about absolute file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('concepts/strings/about.md', concept.about_absolute_filepath)
    end

    test "introduction file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('introduction.md', concept.introduction_filepath)
    end

    test "introduction absolute file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('concepts/strings/introduction.md', concept.introduction_absolute_filepath)
    end

    test "links file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('links.json', concept.links_filepath)
    end

    test "links absolute file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('concepts/strings/links.json', concept.links_absolute_filepath)
    end
  end
end
