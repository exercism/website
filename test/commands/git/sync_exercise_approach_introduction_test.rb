require "test_helper"

class Git::SyncExerciseApproachIntroductionTest < ActiveSupport::TestCase
  test "creates authors and contributors from config" do
    author_1 = create :user, :github
    author_2 = create :user, :github
    contributor = create :user, :github
    exercise = create :practice_exercise
    config = {
      authors: [author_1.github_username, author_2.github_username],
      contributors: [contributor.github_username]
    }

    Git::SyncExerciseApproachIntroduction.(exercise, config)

    assert_equal [author_1, author_2], exercise.approach_introduction_authors
    assert_equal [contributor], exercise.approach_introduction_contributors
  end

  test "updates authors and contributors from config" do
    author_1 = create :user, :github
    author_2 = create :user, :github
    contributor_1 = create :user, :github
    contributor_2 = create :user, :github
    exercise = create :practice_exercise
    exercise.update(approach_introduction_authors: [author_1], approach_introduction_contributors: [contributor_1])
    config = {
      authors: [author_1.github_username, author_2.github_username],
      contributors: [contributor_2.github_username]
    }

    Git::SyncExerciseApproachIntroduction.(exercise, config)

    exercise.reload
    assert_equal [author_1, author_2], exercise.approach_introduction_authors
    assert_equal [contributor_2], exercise.approach_introduction_contributors
  end
end
