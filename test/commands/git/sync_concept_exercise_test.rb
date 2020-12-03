require "test_helper"

class Git::SyncConceptExerciseTest < ActiveSupport::TestCase
  test "does not change when git SHA matches HEAD SHA" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', git_sha: "HEAD", synced_to_git_sha: "HEAD" # rubocop:disable Layout/LineLength

    Git::SyncConceptExercise.(exercise)

    refute exercise.changed?
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "72c4dc096d3f7a5c01c4545d3d6570b5aa3e4252", synced_to_git_sha: "72c4dc096d3f7a5c01c4545d3d6570b5aa3e4252" # rubocop:disable Layout/LineLength
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "git SHA does not change when there are no changes" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "72c4dc096d3f7a5c01c4545d3d6570b5aa3e4252", synced_to_git_sha: "72c4dc096d3f7a5c01c4545d3d6570b5aa3e4252" # rubocop:disable Layout/LineLength
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal "72c4dc096d3f7a5c01c4545d3d6570b5aa3e4252", exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f", synced_to_git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f" # rubocop:disable Layout/LineLength
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .docs files" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "d3e5f7551a68c85c6134275870e00ba7dfa1d612", synced_to_git_sha: "d3e5f7551a68c85c6134275870e00ba7dfa1d612" # rubocop:disable Layout/LineLength
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .meta files" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "14339ac3bc87dd996cd71ae285c252b27c1f45b8", synced_to_git_sha: "14339ac3bc87dd996cd71ae285c252b27c1f45b8" # rubocop:disable Layout/LineLength
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f", synced_to_git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f" # rubocop:disable Layout/LineLength
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "metadata is updated when there are changes in config.json" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f", synced_to_git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f" # rubocop:disable Layout/LineLength
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert exercise.deprecated
  end

  test "removes taught concepts that are not in config.json" do
    track = create :track, slug: 'fsharp'
    numbers = create :track_concept, track: track, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise, track: track, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "27769be83c98b6cc273bc50bbcd2cd31c569cc92", synced_to_git_sha: "27769be83c98b6cc273bc50bbcd2cd31c569cc92" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << conditionals
    exercise.taught_concepts << numbers

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.taught_concepts, numbers
  end

  test "adds new taught concepts defined in config.json" do
    track = create :track, slug: 'fsharp'
    create :track_concept, track: track, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    strings = create :track_concept, track: track, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', deprecated: true, git_sha: "6d0fa1608d257f76ce990eaa5aedf45305bc0a0f", synced_to_git_sha: "6d0fa1608d257f76ce990eaa5aedf45305bc0a0f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << strings

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.taught_concepts, conditionals
  end

  test "removes prerequisites that are not in config.json" do
    track = create :track, slug: 'fsharp'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    strings = create :track_concept, track: track, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    create :track_concept, track: track, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', deprecated: true, git_sha: "4dbfbaca6c68c908d51a979d26baa48ceaefa5c1", synced_to_git_sha: "4dbfbaca6c68c908d51a979d26baa48ceaefa5c1" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.prerequisites << conditionals
    exercise.taught_concepts << strings

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.prerequisites, conditionals
  end

  test "adds new prerequisites defined in config.json" do
    track = create :track, slug: 'fsharp'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, track: track, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    strings = create :track_concept, track: track, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    numbers = create :track_concept, track: track, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', deprecated: true, git_sha: "b6c940e2c321c9b95542bdd5e5018bf447e0fa8a", synced_to_git_sha: "b6c940e2c321c9b95542bdd5e5018bf447e0fa8a" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.prerequisites << conditionals
    exercise.taught_concepts << strings

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.prerequisites, numbers
  end
end
