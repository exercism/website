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
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', git_sha: "9874874b7699998e0be9aad4ae302af81eb4e7a3", synced_to_git_sha: "9874874b7699998e0be9aad4ae302af81eb4e7a3" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal "9874874b7699998e0be9aad4ae302af81eb4e7a3", exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'lazy-logging', title: 'Lazy Logging', deprecated: true, git_sha: "aad5c670f116a1f4a1719a27f6ada26c8fd875de", synced_to_git_sha: "0dae31ad958eb651b66b85853295815a61f485cb" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  # test "track is updated when there are changes" do
  #   track = create :track, slug: "fsharp",
  #                          title: "F#!",
  #                          active: false,
  #                          blurb: "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. F# can elegantly handle almost every problem you throw at it.", # rubocop:disable Layout/LineLength
  #                          git_sha: "f290a29144b93b21e2399cd532b22562d83b6a52"

  #   Git::SyncTrack.(track)

  #   assert_equal "F#", track.title
  #   assert track.active
  #   assert_equal "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. Although F# is great for data science problems, it can elegantly handle almost every problem you throw at it.", track.blurb # rubocop:disable Layout/LineLength
  # end
end
