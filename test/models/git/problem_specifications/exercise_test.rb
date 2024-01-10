require 'test_helper'

class Git::ProblemSpecifications::ExerciseTest < ActiveSupport::TestCase
  test "slug" do
    exercise = Git::ProblemSpecifications::Exercise.new("alphametics", repo_url:)
    assert_equal "alphametics", exercise.slug
  end

  test "title" do
    exercise = Git::ProblemSpecifications::Exercise.new("collatz-conjecture", repo_url:)
    assert_equal "Collatz Conjecture", exercise.title
  end

  test "blurb" do
    exercise = Git::ProblemSpecifications::Exercise.new("collatz-conjecture", repo_url:)
    assert_equal "Calculate the number of steps to reach 1 using the Collatz conjecture.", exercise.blurb
  end

  test "source" do
    exercise = Git::ProblemSpecifications::Exercise.new("collatz-conjecture", repo_url:)
    assert_equal "An unsolved problem in mathematics named after mathematician Lothar Collatz", exercise.source
  end

  test "source_url" do
    exercise = Git::ProblemSpecifications::Exercise.new("collatz-conjecture", repo_url:)
    assert_equal "https://en.wikipedia.org/wiki/3x_%2B_1_problem", exercise.source_url
  end

  test "deprecated?" do
    exercise = Git::ProblemSpecifications::Exercise.new("accumulate", repo_url:)
    assert exercise.deprecated?
  end

  test "not deprecated" do
    exercise = Git::ProblemSpecifications::Exercise.new("bob", repo_url:)
    refute exercise.deprecated?
  end

  test "description file path" do
    exercise = Git::ProblemSpecifications::Exercise.new("high-scores", repo_url:)
    assert_equal "description.md", exercise.description_filepath
  end

  test "description absolute file path" do
    exercise = Git::ProblemSpecifications::Exercise.new("high-scores", repo_url:)
    assert_equal "exercises/high-scores/description.md", exercise.description_absolute_filepath
  end

  test "description" do
    exercise = Git::ProblemSpecifications::Exercise.new("high-scores", repo_url:)
    expected = "# Description\n\nManage a game player's High Score list.\n\nYour task is to build a high-score component of the classic Frogger game, one of the highest selling and most addictive games of all time, and a classic of the arcade era.\nYour task is to write methods that return the highest score from the list, the last added score and the three highest scores." # rubocop:disable Layout/LineLength
    assert_equal expected, exercise.description
  end

  test "metadata file path" do
    exercise = Git::ProblemSpecifications::Exercise.new("anagram", repo_url:)
    assert_equal "metadata.toml", exercise.metadata_filepath
  end

  test "metadata absolute file path" do
    exercise = Git::ProblemSpecifications::Exercise.new("anagram", repo_url:)
    assert_equal "exercises/anagram/metadata.toml", exercise.metadata_absolute_filepath
  end

  test "metadata" do
    exercise = Git::ProblemSpecifications::Exercise.new("anagram", repo_url:)
    expected = {
      "title" => "Anagram",
      "blurb" => "Given a word and a list of possible anagrams, select the correct sublist.",
      "source" => "Inspired by the Extreme Startup game",
      "source_url" => "https://github.com/rchatley/extreme_startup"
    }
    assert_equal expected, exercise.metadata
  end

  test "canonical_data file path" do
    exercise = Git::ProblemSpecifications::Exercise.new("hello-world", repo_url:)
    assert_equal "canonical-data.json", exercise.canonical_data_filepath
  end

  test "canonical_data absolute file path" do
    exercise = Git::ProblemSpecifications::Exercise.new("hello-world", repo_url:)
    assert_equal "exercises/hello-world/canonical-data.json", exercise.canonical_data_absolute_filepath
  end

  test "canonical_data" do
    exercise = Git::ProblemSpecifications::Exercise.new("hello-world", repo_url:)
    expected = {
      exercise: "hello-world",
      cases: [
        {
          uuid: "af9ffe10-dc13-42d8-a742-e7bdafac449d",
          description: "Say Hi!",
          property: "hello",
          input: {},
          expected: "Hello, World!"
        }
      ]
    }
    assert_equal expected, exercise.canonical_data
  end

  private
  def repo_url = TestHelpers.git_repo_url("problem-specifications")

  # test "content file path" do
  #   approach = Git::Exercise::Approach.new("readability", "hamming", "practice", "HEAD",
  #     repo_url: TestHelpers.git_repo_url("track"))
  #   assert_equal('content.md', approach.content_filepath)
  # end

  # test "content absolute file path" do
  #   approach = Git::Exercise::Approach.new("readability", "hamming", "practice", "HEAD",
  #     repo_url: TestHelpers.git_repo_url("track"))
  #   assert_equal('exercises/practice/hamming/.approaches/readability/content.md', approach.content_absolute_filepath)
  # end

  # test "snippet" do
  #   approach = Git::Exercise::Approach.new("readability", "hamming", "practice", "HEAD",
  #     repo_url: TestHelpers.git_repo_url("track"))

  #   assert_equal "READABILITY", approach.snippet
  # end

  # test "snippet file path" do
  #   approach = Git::Exercise::Approach.new("readability", "hamming", "practice", "HEAD",
  #     repo_url: TestHelpers.git_repo_url("track"))
  #   assert_equal('snippet.txt', approach.snippet_filepath)
  # end

  # test "snippet absolute file path" do
  #   approach = Git::Exercise::Approach.new("readability", "hamming", "practice", "HEAD",
  #     repo_url: TestHelpers.git_repo_url("track"))
  #   assert_equal('exercises/practice/hamming/.approaches/readability/snippet.txt', approach.snippet_absolute_filepath)
  # end
end
