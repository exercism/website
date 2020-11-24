require "test_helper"

class Git::SyncExerciseTest < ActiveSupport::TestCase
  test "no change when git SHA matches HEAD SHA" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', git_sha: "HEAD", synced_to_git_sha: "HEAD" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    refute exercise.changed?
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', git_sha: "9874874b7699998e0be9aad4ae302af81eb4e7a3", synced_to_git_sha: "9874874b7699998e0be9aad4ae302af81eb4e7a3" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "git SHA does not change when there are no changes" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: 'Lucian\'s Luscious Lasagna', git_sha: "9874874b7699998e0be9aad4ae302af81eb4e7a3", synced_to_git_sha: "9874874b7699998e0be9aad4ae302af81eb4e7a3" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal "9874874b7699998e0be9aad4ae302af81eb4e7a3", exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels!', deprecated: true, git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e", synced_to_git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .docs files" do
    skip

    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: 'Lucian\'s Luscious Lasagna', git_sha: "ad3893d6231d11bcbb3c2898c4629f5cbae3b76c", synced_to_git_sha: "ad3893d6231d11bcbb3c2898c4629f5cbae3b76c" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .meta files" do
    skip

    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "c1a216f90aa2e18df78ab24ae1f99b0a5dfcec0f", synced_to_git_sha: "c1a216f90aa2e18df78ab24ae1f99b0a5dfcec0f" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    skip

    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: 'd605385d-fd8a-45fa-a320-4d7c40213769', slug: 'guessing-game', title: 'Guessing game', git_sha: "90d4f30cda48b4f58d3ac7353c259ff865d6e136", synced_to_git_sha: "90d4f30cda48b4f58d3ac7353c259ff865d6e136" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "exercise is updated when there are changes in config.json" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise,
      track: track,
      uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125',
      slug: 'log-levels',
      title: 'Log Levels',
      deprecated: false,
      git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e",
      synced_to_git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e"

    Git::SyncExercise.(exercise)

    assert_equal "log-levels!", exercise.slug
    assert_equal "Log Levels!", exercise.title
    assert exercise.deprecated
  end
end
