require "test_helper"

class ProblemSpecifications::ExerciseTest < ActiveSupport::TestCase
  test "title" do
    exercise = ProblemSpecifications::Exercise.new("anagram", repo:)
    assert_equal "Anagram", exercise.title
  end

  test "blurb" do
    exercise = ProblemSpecifications::Exercise.new("anagram", repo:)
    assert_equal "Given a word and a list of possible anagrams, select the correct sublist.", exercise.blurb
  end

  test "source" do
    exercise = ProblemSpecifications::Exercise.new("anagram", repo:)
    assert_equal "Inspired by the Extreme Startup game", exercise.source
  end

  test "source_url" do
    exercise = ProblemSpecifications::Exercise.new("anagram", repo:)
    assert_equal "https://github.com/rchatley/extreme_startup", exercise.source_url
  end

  test "deprecated?" do
    exercise = ProblemSpecifications::Exercise.new("accumulate", repo:)
    assert exercise.deprecated?
  end

  test "not deprecated?" do
    exercise = ProblemSpecifications::Exercise.new("bob", repo:)
    refute exercise.deprecated?
  end

  test "url" do
    exercise = ProblemSpecifications::Exercise.new("bob", repo:)
    assert_equal "https://github.com/exercism/problem-specifications/tree/main/exercises/bob", exercise.url
  end

  test "icon_url" do
    exercise = ProblemSpecifications::Exercise.new("bob", repo:)
    assert_equal "https://assets.exercism.org/exercises/bob.svg", exercise.icon_url
  end

  private
  def repo
    repo_url = TestHelpers.git_repo_url("problem-specifications")
    Git::Repository.new(repo_url:)
  end
end
