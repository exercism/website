require "test_helper"

class Git::SyncPracticeExerciseTest < ActiveSupport::TestCase
  test "no change when git SHA matches HEAD SHA" do
    # TODO: re-enable once we import practice exercises
    skip

    track = create :track, slug: 'fsharp'
    exercise = create :practice_exercise, track: track, uuid: '302312cc-bd15-4ba0-8f2f-cbf411c40186', slug: 'hello-world', title: 'Hello World', git_sha: "HEAD", synced_to_git_sha: "HEAD" # rubocop:disable Layout/LineLength

    Git::SyncPracticeExercise.(exercise)

    refute exercise.changed?
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    # TODO: re-enable once we import practice exercises
    skip

    track = create :track, slug: 'fsharp'
    exercise = create :practice_exercise, track: track, uuid: '302312cc-bd15-4ba0-8f2f-cbf411c40186', slug: 'hello-world', title: 'Hello World', git_sha: "171577814bd42a0ed0880b9c28016b26688c51ab", synced_to_git_sha: "171577814bd42a0ed0880b9c28016b26688c51ab" # rubocop:disable Layout/LineLength

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    skip

    # TODO: implement
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels!', deprecated: true, git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e", synced_to_git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e" # rubocop:disable Layout/LineLength
    create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    create :track_concept, track: track, slug: 'the-basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    create :track_concept, track: track, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in documentation files" do
    skip

    # TODO: implement
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "6c4eae85df5edc9b355c3ed8c665579d272ebc8c", synced_to_git_sha: "6c4eae85df5edc9b355c3ed8c665579d272ebc8c" # rubocop:disable Layout/LineLength
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, track: track, slug: 'the-basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    numbers = create :track_concept, track: track, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    exercise.taught_concepts << conditionals
    exercise.taught_concepts << numbers
    exercise.prerequisites << basics

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    skip

    # TODO: implement

    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: 'Lucian\'s Luscious Lasagna', git_sha: "d098419839aa89d0efafe7a5f30e5214540384e8", synced_to_git_sha: "d098419839aa89d0efafe7a5f30e5214540384e8" # rubocop:disable Layout/LineLength
    basics = create :track_concept, track: track, slug: 'the-basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.taught_concepts << basics

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "metadata is updated when there are changes in config.json" do
    skip

    # TODO: implement

    track = create :track, slug: 'fsharp'
    strings = create :track_concept, track: track, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, track: track, slug: 'the-basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise,
      track: track,
      uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125',
      slug: 'log-levels',
      title: 'Log Levels',
      deprecated: false,
      git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e",
      synced_to_git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e"
    exercise.taught_concepts << strings
    exercise.prerequisites << basics
    exercise.prerequisites << conditionals

    Git::SyncPracticeExercise.(exercise)

    assert_equal "log-levels!", exercise.slug
    assert_equal "Log Levels!", exercise.title
    assert exercise.deprecated
  end

  test "adds new prerequisites defined in config.json" do
    skip

    # TODO: implement

    track = create :track, slug: 'fsharp'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, track: track, slug: 'the-basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    numbers = create :track_concept, track: track, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    exercise = create :concept_exercise,
      track: track,
      uuid: '6ea2765e-5885-11ea-82b4-0242ac130003',
      slug: 'cars-assemble',
      title: 'Cars, Assemble!',
      deprecated: true,
      git_sha: "98aa6c99837cf312d06734a085307e0327cb42a3",
      synced_to_git_sha: "98aa6c99837cf312d06734a085307e0327cb42a3"
    exercise.taught_concepts << conditionals
    exercise.prerequisites << basics

    Git::SyncPracticeExercise.(exercise)

    assert_includes exercise.taught_concepts, numbers
  end

  test "removes prerequisites that are not in config.json" do
    skip

    # TODO: implement

    track = create :track, slug: 'fsharp'
    numbers = create :track_concept, track: track, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    create :track_concept, track: track, slug: 'the-basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    create :track_concept, track: track, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    exercise = create :concept_exercise,
      track: track,
      uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125',
      slug: 'log-levels!',
      title: 'Log Levels!',
      deprecated: true,
      git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e",
      synced_to_git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e"
    exercise.prerequisites << numbers
    exercise.prerequisites << conditionals

    Git::SyncPracticeExercise.(exercise)

    refute_includes exercise.prerequisites, numbers
  end
end
