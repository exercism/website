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
    conditionals = create :track_concept, track: track, slug: 'pattern-matching', uuid: '3439b5d6-6e1b-486b-989d-9f7e8f9eb732' # rubocop:disable Layout/LineLength
    exercise = create :concept_exercise, track: track, uuid: 'd605385d-fd8a-45fa-a320-4d7c40213769', slug: 'guessing-game', title: 'Guessing game', git_sha: "8f10cdff3f00cfa5f1daf86b4ab589118e54a5cb", synced_to_git_sha: "8f10cdff3f00cfa5f1daf86b4ab589118e54a5cb" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << conditionals

    Git::SyncExercise.(exercise)

    assert_equal "8f10cdff3f00cfa5f1daf86b4ab589118e54a5cb", exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels!', deprecated: true, git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e", synced_to_git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .docs files" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "6c4eae85df5edc9b355c3ed8c665579d272ebc8c", synced_to_git_sha: "6c4eae85df5edc9b355c3ed8c665579d272ebc8c" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .meta files" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: 'd605385d-fd8a-45fa-a320-4d7c40213769', slug: 'guessing-game', title: 'Guessing game', git_sha: "99126fe27cbf9e9cb7dd06865840b3f8a44c7e16", synced_to_git_sha: "99126fe27cbf9e9cb7dd06865840b3f8a44c7e16" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    track = create :track, slug: 'fsharp'
    exercise = create :concept_exercise, track: track, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: 'Lucian\'s Luscious Lasagna', git_sha: "d098419839aa89d0efafe7a5f30e5214540384e8", synced_to_git_sha: "d098419839aa89d0efafe7a5f30e5214540384e8" # rubocop:disable Layout/LineLength

    Git::SyncExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "metadata is updated when there are changes in config.json" do
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

  test "removes taught concepts that are not in config.json" do
    track = create :track, slug: 'fsharp'
    strings = create :track_concept, track: track, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    exercise = create :concept_exercise,
      track: track,
      uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125',
      slug: 'log-levels!',
      title: 'Log Levels!',
      deprecated: true,
      git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e",
      synced_to_git_sha: "afa3b42c421aa37295bce1da3b4107ac42d1c20e"
    exercise.taught_concepts << strings
    exercise.taught_concepts << conditionals

    Git::SyncExercise.(exercise)

    refute_includes exercise.taught_concepts, conditionals
  end

  test "adds new taught concepts defined in config.json" do
    track = create :track, slug: 'fsharp'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    exercise = create :concept_exercise,
      track: track,
      uuid: '6ea2765e-5885-11ea-82b4-0242ac130003',
      slug: 'cars-assemble',
      title: 'Cars, Assemble!',
      deprecated: true,
      git_sha: "98aa6c99837cf312d06734a085307e0327cb42a3",
      synced_to_git_sha: "98aa6c99837cf312d06734a085307e0327cb42a3"
    exercise.taught_concepts << conditionals

    Git::SyncExercise.(exercise)

    numbers = ::Track::Concept.find_by(uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3')
    assert_includes exercise.taught_concepts, numbers
  end

  test "removes prerequisite that are not in config.json" do
    track = create :track, slug: 'fsharp'
    numbers = create :track_concept, track: track, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
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

    Git::SyncExercise.(exercise)

    refute_includes exercise.prerequisites, numbers
  end

  test "adds new prerequisites defined in config.json" do
    track = create :track, slug: 'fsharp'
    conditionals = create :track_concept, track: track, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    exercise = create :concept_exercise,
      track: track,
      uuid: '6ea2765e-5885-11ea-82b4-0242ac130003',
      slug: 'cars-assemble',
      title: 'Cars, Assemble!',
      deprecated: true,
      git_sha: "98aa6c99837cf312d06734a085307e0327cb42a3",
      synced_to_git_sha: "98aa6c99837cf312d06734a085307e0327cb42a3"
    exercise.prerequisites << conditionals

    Git::SyncExercise.(exercise)

    basics = ::Track::Concept.find_by(uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215')
    assert_includes exercise.prerequisites, basics
  end
end
