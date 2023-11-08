require "test_helper"

class Exercise::ApproachTest < ActiveSupport::TestCase
  test "exercise wired in correctly" do
    exercise = create :practice_exercise

    approach = create(:exercise_approach, exercise:)
    assert_equal exercise, approach.exercise
    assert_equal [approach], exercise.approaches
  end

  test "authors wired in correctly" do
    author_1 = create :user
    author_2 = create :user

    approach = create :exercise_approach
    create :exercise_approach_authorship, approach:, author: author_1
    create :exercise_approach_authorship, approach:, author: author_2

    assert_equal [author_1, author_2], approach.authors
    assert_equal [approach], author_1.authored_approaches
    assert_equal [approach], author_2.authored_approaches
  end

  test "contributors wired in correctly" do
    contributor_1 = create :user
    contributor_2 = create :user

    approach = create :exercise_approach
    create :exercise_approach_contributorship, approach:, contributor: contributor_1
    create :exercise_approach_contributorship, approach:, contributor: contributor_2

    assert_equal [contributor_1, contributor_2], approach.contributors
    assert_equal [approach], contributor_1.contributed_approaches
    assert_equal [approach], contributor_2.contributed_approaches
  end

  test "content" do
    exercise = create :practice_exercise, slug: 'hamming'
    approach = create(:exercise_approach, exercise:)

    assert_equal "# Description\n\nReadability approach", approach.content
  end

  test "snippet" do
    exercise = create :practice_exercise, slug: 'hamming'
    approach = create(:exercise_approach, exercise:)

    assert_equal "READABILITY", approach.snippet
  end

  test "matches_tags?" do
    tags = nil
    approach = create(:exercise_approach, tags:)
    refute approach.matches_tags?([])
    refute approach.matches_tags?(["construct:if"])

    tags = {}
    approach.update(tags:)
    refute approach.matches_tags?([])
    refute approach.matches_tags?(["construct:if"])

    tags["all"] = ["construct:if"]
    approach.update(tags:)
    refute approach.matches_tags?([])
    assert approach.matches_tags?(["construct:if"])

    tags["any"] = ["construct:for"]
    approach.update(tags:)
    refute approach.matches_tags?([])
    refute approach.matches_tags?(["construct:if"])
    assert approach.matches_tags?(["construct:if", "construct:for"])

    tags["not"] = ["construct:do"]
    approach.update(tags:)
    refute approach.matches_tags?([])
    refute approach.matches_tags?(["construct:if"])
    assert approach.matches_tags?(["construct:if", "construct:for"])
    refute approach.matches_tags?(["construct:if", "construct:for", "construct:do"])

    tags["any"] << "construct:repeat"
    approach.update(tags:)
    refute approach.matches_tags?([])
    refute approach.matches_tags?(["construct:if"])
    refute approach.matches_tags?(["construct:repeat"])
    refute approach.matches_tags?(["construct:for", "construct:repeat"])
    assert approach.matches_tags?(["construct:if", "construct:for"])
    assert approach.matches_tags?(["construct:repeat", "construct:if"])

    tags["all"] << "construct:while"
    approach.update(tags:)
    refute approach.matches_tags?([])
    refute approach.matches_tags?(["construct:if"])
    refute approach.matches_tags?(["construct:repeat"])
    refute approach.matches_tags?(["construct:for", "construct:repeat"])
    refute approach.matches_tags?(["construct:if", "construct:for"])
    refute approach.matches_tags?(["construct:repeat", "construct:if"])
    refute approach.matches_tags?(["construct:if", "construct:for"])
    assert approach.matches_tags?(["construct:repeat", "construct:if", "construct:while"])
    refute approach.matches_tags?(["construct:repeat", "construct:if", "construct:do", "construct:while"])
  end
end
