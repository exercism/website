require "test_helper"

class Git::SyncPracticeExerciseTest < ActiveSupport::TestCase
  test "git sync SHA changes to HEAD SHA when there are no changes" do
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3', slug: 'bob', title: 'Bob', git_sha: "c4701190aa99d47b7e92e5c1605659a4f08d6776", synced_to_git_sha: "c4701190aa99d47b7e92e5c1605659a4f08d6776" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca')
    exercise.prerequisites << (create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'Allergies', git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7", synced_to_git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'arrays', uuid: '55b8bfe8-4c8c-460b-ab78-b3f384b6f313')

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in documentation files" do
    exercise = create :practice_exercise, uuid: 'd5644b3c-5d48-4d31-b208-b6365b10c0db', slug: 'anagram', title: 'Anagram', git_sha: "e6927df782dd5c348054b12c8d6c3216b644d715", synced_to_git_sha: "e6927df782dd5c348054b12c8d6c3216b644d715" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    exercise = create :practice_exercise, uuid: '53603e05-2051-4904-a181-e358390f9ae7', slug: 'hamming', title: 'hamming', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "metadata is updated when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'Allergies', git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7", synced_to_git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'arrays', uuid: '55b8bfe8-4c8c-460b-ab78-b3f384b6f313')

    Git::SyncPracticeExercise.(exercise)

    assert_equal "Allergies Alert", exercise.title
  end

  test "adds new prerequisites defined in config.json" do
    exercise = create :practice_exercise, uuid: '4f12ede3-312e-482a-b0ae-dfd29f10b5fb', slug: 'leap', title: 'Leap', git_sha: "e84f87c9c527a2bbeb72e8013d32114809f1bee9", synced_to_git_sha: "e84f87c9c527a2bbeb72e8013d32114809f1bee9" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'numbers', uuid: '162721bd-3d64-43ff-889e-6fb2eac75709')
    conditionals = create :track_concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca'

    Git::SyncPracticeExercise.(exercise)

    assert_includes exercise.prerequisites, conditionals
  end

  test "removes prerequisites that are not in config.json" do
    time = create :track_concept, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    exercise = create :practice_exercise, uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206', slug: 'space-age', title: 'Space Age', git_sha: "503834363624c44f1202953427e7047f0472cbe7", synced_to_git_sha: "503834363624c44f1202953427e7047f0472cbe7" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a')
    exercise.prerequisites << time

    Git::SyncPracticeExercise.(exercise)

    refute_includes exercise.prerequisites, time
  end
end
