require "test_helper"

class Git::SyncExerciseArticleTest < ActiveSupport::TestCase
  test "creates article from config" do
    exercise = create :practice_exercise
    config = { uuid: SecureRandom.uuid, slug: "performance", title: "Performance", blurb: "Speed up!" }

    article = Git::SyncExerciseArticle.(exercise, config, 1)

    assert_equal exercise, article.exercise
    assert_equal config[:slug], article.slug
    assert_equal config[:title], article.title
    assert_equal config[:blurb], article.blurb
    assert_equal article.git.head_sha, article.synced_to_git_sha
    assert_equal 1, article.position
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

    article = Git::SyncExerciseArticle.(exercise, config, 1)

    assert_equal [author_1, author_2], article.authors
    assert_equal [contributor], article.contributors
  end

  test "updates article from config value" do
    exercise = create :practice_exercise
    article = create(:exercise_article, exercise:)
    config = { uuid: article.uuid, slug: "new slug", title: "new title", blurb: "new blurb" }

    Git::SyncExerciseArticle.(exercise, config, 2)

    article.reload
    assert_equal exercise, article.exercise
    assert_equal config[:slug], article.slug
    assert_equal config[:title], article.title
    assert_equal config[:blurb], article.blurb
    assert_equal 2, article.position
    assert_equal article.git.head_sha, article.synced_to_git_sha
  end

  test "updates authors and contributors from config" do
    author_1 = create :user, :github
    author_2 = create :user, :github
    contributor_1 = create :user, :github
    contributor_2 = create :user, :github
    exercise = create :practice_exercise
    article = create(:exercise_article, exercise:)
    article.update(authors: [author_1], contributors: [contributor_1])
    config = article.slice(:uuid, :slug, :title, :blurb).merge({
      authors: [author_1.github_username, author_2.github_username],
      contributors: [contributor_2.github_username]
    })

    Git::SyncExerciseArticle.(exercise, config, 1)

    article.reload
    assert_equal [author_1, author_2], article.authors
    assert_equal [contributor_2], article.contributors
  end

  test "does not change updated_at when values haven't changed" do
    updated_at = Time.zone.now - 2.days
    exercise = create :practice_exercise
    article = create :exercise_article, exercise:, updated_at:, synced_to_git_sha: exercise.git.head_sha
    config = article.slice(:uuid, :slug, :title, :blurb)

    Git::SyncExerciseArticle.(exercise, config, 1)

    article.reload
    assert_equal updated_at, article.updated_at
  end
end
