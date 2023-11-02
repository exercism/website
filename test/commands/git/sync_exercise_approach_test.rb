require "test_helper"

class Git::SyncExerciseApproachTest < ActiveSupport::TestCase
  test "creates approach from config" do
    exercise = create :practice_exercise
    config = { uuid: SecureRandom.uuid, slug: "performance", title: "Performance", blurb: "Speed up!" }

    approach = Git::SyncExerciseApproach.(exercise, config)

    assert_equal exercise, approach.exercise
    assert_equal config[:slug], approach.slug
    assert_equal config[:title], approach.title
    assert_equal config[:blurb], approach.blurb
    assert_equal approach.git.head_sha, approach.synced_to_git_sha
  end

  test "creates authors and contributors from config" do
    author_1 = create :user, :github
    author_2 = create :user, :github
    contributor = create :user, :github
    exercise = create :practice_exercise
    config = {
      uuid: SecureRandom.uuid,
      slug: "performance",
      title: "Performance",
      blurb: "Speed up!",
      authors: [author_1.github_username, author_2.github_username],
      contributors: [contributor.github_username]
    }

    approach = Git::SyncExerciseApproach.(exercise, config)

    assert_equal [author_1, author_2], approach.authors
    assert_equal [contributor], approach.contributors
  end

  test "updates approach from config value" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    config = { uuid: approach.uuid, slug: "new slug", title: "new title", blurb: "new blurb" }

    Git::SyncExerciseApproach.(exercise, config)

    approach.reload
    assert_equal exercise, approach.exercise
    assert_equal config[:slug], approach.slug
    assert_equal config[:title], approach.title
    assert_equal config[:blurb], approach.blurb
    assert_equal approach.git.head_sha, approach.synced_to_git_sha
  end

  test "updates authors and contributors from config" do
    author_1 = create :user, :github
    author_2 = create :user, :github
    contributor_1 = create :user, :github
    contributor_2 = create :user, :github
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    approach.update(authors: [author_1], contributors: [contributor_1])
    config = approach.slice(:uuid, :slug, :title, :blurb).merge({
      authors: [author_1.github_username, author_2.github_username],
      contributors: [contributor_2.github_username]
    })

    Git::SyncExerciseApproach.(exercise, config)

    approach.reload
    assert_equal [author_1, author_2], approach.authors
    assert_equal [contributor_2], approach.contributors
  end

  test "does not change updated_at when values haven't changed" do
    updated_at = Time.zone.now - 2.days
    exercise = create :practice_exercise
    approach = create :exercise_approach, exercise:, updated_at:, synced_to_git_sha: exercise.git.head_sha
    config = approach.slice(:uuid, :slug, :title, :blurb)

    Git::SyncExerciseApproach.(exercise, config)

    approach.reload
    assert_equal updated_at, approach.updated_at
  end

  test "creates tags from config" do
    exercise = create :practice_exercise
    config = {
      uuid: SecureRandom.uuid,
      slug: "performance",
      title: "Performance",
      blurb: "Speed up!",
      tags: {
        all: ["paradigm:functional"],
        any: ["construct:lambda", "technique:higher-order-function"],
        not: ["paradigm:imperative"]
      }
    }

    approach = Git::SyncExerciseApproach.(exercise, config)

    assert_equal 4, approach.tags.count

    functional_tag = approach.tags.find { |tag| tag.tag == "paradigm:functional" }
    refute_nil functional_tag
    assert_equal :all, functional_tag.condition_type

    lambda_tag = approach.tags.find { |tag| tag.tag == "construct:lambda" }
    refute_nil lambda_tag
    assert_equal :any, lambda_tag.condition_type

    higher_order_functions_tag = approach.tags.find { |tag| tag.tag == "technique:higher-order-function" }
    refute_nil higher_order_functions_tag
    assert_equal :any, higher_order_functions_tag.condition_type

    imperative_tag = approach.tags.find { |tag| tag.tag == "paradigm:imperative" }
    refute_nil imperative_tag
    assert_equal :not, imperative_tag.condition_type
  end

  test "updates tags from config" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, approach:, tag: "paradigm:functional", condition_type: :not)
    create(:exercise_approach_tag, approach:, tag: "technique:higher-order-function", condition_type: :any)
    create(:exercise_approach_tag, approach:, tag: "construct:string", condition_type: :all)

    config = {
      uuid: approach.uuid,
      slug: approach.slug,
      title: approach.title,
      blurb: approach.blurb,
      tags: {
        all: ["paradigm:functional"],
        any: ["construct:lambda", "technique:higher-order-function"],
        not: ["paradigm:imperative"]
      }
    }

    approach = Git::SyncExerciseApproach.(exercise, config)

    assert_equal 4, approach.tags.count

    functional_tag = approach.tags.find { |tag| tag.tag == "paradigm:functional" }
    refute_nil functional_tag
    assert_equal :all, functional_tag.condition_type

    lambda_tag = approach.tags.find { |tag| tag.tag == "construct:lambda" }
    refute_nil lambda_tag
    assert_equal :any, lambda_tag.condition_type

    higher_order_functions_tag = approach.tags.find { |tag| tag.tag == "technique:higher-order-function" }
    refute_nil higher_order_functions_tag
    assert_equal :any, higher_order_functions_tag.condition_type

    imperative_tag = approach.tags.find { |tag| tag.tag == "paradigm:imperative" }
    refute_nil imperative_tag
    assert_equal :not, imperative_tag.condition_type
  end
end
