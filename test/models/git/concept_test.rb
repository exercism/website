require 'test_helper'

module Git
  class ConceptTest < ActiveSupport::TestCase
    test "about" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))

      expected = "A String object holds and manipulates an arbitrary sequence of bytes, typically representing characters. String objects may be created using ::new or as literals." # rubocop:disable Layout/LineLength
      assert_equal expected, concept.about
    end

    test "introduction" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))

      expected = "A String object holds and manipulates an arbitrary sequence of bytes, typically representing characters."
      assert_equal expected, concept.introduction
    end

    test "links" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))

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

    test "blurb" do
      concept = Git::Concept.new(:strings, "58cf32eb00c3deb636779c94799c66305d1b7518",
        repo_url: TestHelpers.git_repo_url("track"))

      assert_equal "Strings are immutable objects", concept.blurb
    end

    test "about file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('about.md', concept.about_filepath)
    end

    test "about absolute file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('concepts/strings/about.md', concept.about_absolute_filepath)
    end

    test "introduction file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('introduction.md', concept.introduction_filepath)
    end

    test "introduction absolute file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('concepts/strings/introduction.md', concept.introduction_absolute_filepath)
    end

    test "links file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('links.json', concept.links_filepath)
    end

    test "links absolute file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('concepts/strings/links.json', concept.links_absolute_filepath)
    end

    test "config file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('.meta/config.json', concept.config_filepath)
    end

    test "config absolute file path" do
      concept = Git::Concept.new(:strings, "29537dca4c78e76fcab1e188a71b629223764407",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('concepts/strings/.meta/config.json', concept.config_absolute_filepath)
    end
  end
end
