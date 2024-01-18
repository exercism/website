require "test_helper"

class Git::SyncExerciseApproachTest < ActiveSupport::TestCase
  test "creates approach from config" do
    exercise = create :practice_exercise
    config = { uuid: SecureRandom.uuid, slug: "performance", title: "Performance", blurb: "Speed up!" }

    approach = Git::SyncExerciseApproach.(exercise, config, 1)

    assert_equal exercise, approach.exercise
    assert_equal config[:slug], approach.slug
    assert_equal config[:title], approach.title
    assert_equal config[:blurb], approach.blurb
    assert_equal approach.git.head_sha, approach.synced_to_git_sha
    assert_equal 1, approach.position
    assert_nil approach.tags
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

    approach = Git::SyncExerciseApproach.(exercise, config, 1)

    assert_equal [author_1, author_2], approach.authors
    assert_equal [contributor], approach.contributors
  end

  test "updates approach from config value" do
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    config = { uuid: approach.uuid, slug: "new slug", title: "new title", blurb: "new blurb" }

    Git::SyncExerciseApproach.(exercise, config, 2)

    approach.reload
    assert_equal exercise, approach.exercise
    assert_equal config[:slug], approach.slug
    assert_equal config[:title], approach.title
    assert_equal config[:blurb], approach.blurb
    assert_equal 2, approach.position
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

    Git::SyncExerciseApproach.(exercise, config, 1)

    approach.reload
    assert_equal [author_1, author_2], approach.authors
    assert_equal [contributor_2], approach.contributors
  end

  test "does not change updated_at when values haven't changed" do
    updated_at = Time.zone.now - 2.days
    exercise = create :practice_exercise
    approach = create :exercise_approach, exercise:, updated_at:, synced_to_git_sha: exercise.git.head_sha
    config = approach.slice(:uuid, :slug, :title, :blurb)

    Git::SyncExerciseApproach.(exercise, config, 1)

    approach.reload
    assert_equal updated_at, approach.updated_at
  end

  test "creates tags from config" do
    tags = {
      "all" => ["paradigm:functional"],
      "any" => ["construct:lambda", "technique:higher-order-function"],
      "not" => ["paradigm:imperative"]
    }
    exercise = create :practice_exercise
    config = {
      uuid: SecureRandom.uuid,
      slug: "performance",
      title: "Performance",
      blurb: "Speed up!",
      tags:
    }

    approach = Git::SyncExerciseApproach.(exercise, config, 1)

    assert_equal tags, approach.tags
  end

  test "updates tags from config" do
    tags = {
      "all" => ["construct:string"],
      "any" => ["technique:higher-order-function"],
      "not" => ["paradigm:functional"]
    }
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:, tags:)

    new_tags = {
      "all" => ["paradigm:functional"],
      "any" => ["construct:lambda", "technique:higher-order-function"],
      "not" => ["paradigm:imperative"]
    }

    config = {
      uuid: approach.uuid,
      slug: approach.slug,
      title: approach.title,
      blurb: approach.blurb,
      tags: new_tags
    }

    Git::SyncExerciseApproach.(exercise, config, 1)

    assert_equal new_tags, approach.reload.tags
  end

  test "link submissions when creating approach with tags" do
    exercise = create :practice_exercise
    config = {
      uuid: SecureRandom.uuid,
      slug: "performance",
      title: "Performance",
      blurb: "Speed up!",
      tags: {
        "all" => ["paradigm:functional"]
      }
    }

    Exercise::Approach::LinkMatchingSubmissions.expects(:call).once

    Git::SyncExerciseApproach.(exercise, config, 1)
  end

  test "don't link submissions when creating approach without tags" do
    exercise = create :practice_exercise
    config = { uuid: SecureRandom.uuid, slug: "performance", title: "Performance", blurb: "Speed up!" }

    Exercise::Approach::LinkMatchingSubmissions.expects(:call).never

    Git::SyncExerciseApproach.(exercise, config, 1)
  end

  test "link submissions when tags are updated from config" do
    tags = { "any" => %w[paradigm:imperative paradigm:functional] }
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:, tags:)

    config = approach.slice(:uuid, :slug, :title, :blurb)
    config[:tags] = { "all" => %w[paradigm:imperative] }

    Exercise::Approach::LinkMatchingSubmissions.expects(:call).with(approach)

    Git::SyncExerciseApproach.(exercise, config, 1)
  end

  test "don't link submissions when tags haven't changed" do
    tags = { "any" => %w[paradigm:imperative paradigm:functional] }
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:, tags:)

    config = approach.slice(:uuid, :slug, :title, :blurb, :tags)

    Exercise::Approach::LinkMatchingSubmissions.expects(:call).with(approach).never

    Git::SyncExerciseApproach.(exercise, config, 1)
  end
end
