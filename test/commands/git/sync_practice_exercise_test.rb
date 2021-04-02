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
    assert_equal "Allergic? Try this!", exercise.blurb
  end

  test "position is updated when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: '53603e05-2051-4904-a181-e358390f9ae7', position: 1, slug: 'hamming', title: 'hamming', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal 9, exercise.position
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

  test "adds new practiced concepts defined in config.json" do
    time = create :track_concept, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    dates = create :track_concept, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a'
    exercise = create :practice_exercise, uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206', slug: 'space-age', title: 'Space Age', git_sha: "503834363624c44f1202953427e7047f0472cbe7", synced_to_git_sha: "503834363624c44f1202953427e7047f0472cbe7" # rubocop:disable Layout/LineLength

    Git::SyncPracticeExercise.(exercise)

    assert_equal [dates, time], exercise.practiced_concepts
  end

  test "removes practiced concepts that are not in config.json" do
    time = create :track_concept, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    dates = create :track_concept, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a'
    conditionals = create :track_concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca'
    exercise = create :practice_exercise, uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206', slug: 'space-age', title: 'Space Age', git_sha: "503834363624c44f1202953427e7047f0472cbe7", synced_to_git_sha: "503834363624c44f1202953427e7047f0472cbe7" # rubocop:disable Layout/LineLength
    exercise.practiced_concepts << dates
    exercise.practiced_concepts << time
    exercise.practiced_concepts << conditionals

    Git::SyncPracticeExercise.(exercise)

    assert_equal [time, dates], exercise.practiced_concepts
  end

  test "adds authors that are in .meta/config.json" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'allergies', git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a', synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a' # rubocop:disable Layout/LineLength
    new_author = create :user, github_username: 'ErikSchierboom'

    Git::SyncPracticeExercise.(exercise)

    assert_equal 1, exercise.authors.size
    assert_includes exercise.authors, new_author
  end

  test "removes authors that are not in .meta/config.json" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'allergies', git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a', synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a' # rubocop:disable Layout/LineLength
    old_author = create :user, github_username: 'iHiD'
    exercise.authors << old_author

    Git::SyncPracticeExercise.(exercise)

    refute exercise.authors.where(github_username: old_author.github_username).exists?
  end

  test "adds reputation token for new author" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'allergies', git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a', synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a' # rubocop:disable Layout/LineLength
    new_author = create :user, github_username: 'ErikSchierboom'

    Git::SyncPracticeExercise.(exercise)

    new_authorship = exercise.authorships.find_by(author: new_author)
    new_author_rep_token = new_author.reputation_tokens.last
    assert_equal :authoring, new_author_rep_token.category
    assert_equal :authored_exercise, new_author_rep_token.reason
    assert_equal 20, new_author_rep_token.value
    assert_equal new_authorship, new_author_rep_token.authorship
  end

  test "does not add reputation token for existing author" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'allergies', git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a', synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a' # rubocop:disable Layout/LineLength
    existing_author = create :user, github_username: 'ErikSchierboom'

    existing_author_authorship = create :exercise_authorship, exercise: exercise, author: existing_author
    create :user_exercise_author_reputation_token, user: existing_author, params: { authorship: existing_author_authorship }

    Git::SyncPracticeExercise.(exercise)

    assert_equal 1, existing_author.reputation_tokens.where(category: "authoring").count
  end

  test "adds contributors that are in .meta/config.json" do
    contributor = create :user, github_username: 'iHiD'
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3', slug: 'bob', title: 'Bob', git_sha: '0ec511318983b7d27d6a27410509071ee7683e52', synced_to_git_sha: '0ec511318983b7d27d6a27410509071ee7683e52' # rubocop:disable Layout/LineLength

    Git::SyncPracticeExercise.(exercise)

    assert_equal 1, exercise.contributors.size
    assert_includes exercise.contributors, contributor
  end

  test "removes contributors that are not in .meta/config.json" do
    old_contributor = create :user, github_username: "ErikSchierboom"
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3', slug: 'bob', title: 'Bob', git_sha: '0ec511318983b7d27d6a27410509071ee7683e52', synced_to_git_sha: '0ec511318983b7d27d6a27410509071ee7683e52' # rubocop:disable Layout/LineLength
    exercise.contributors << old_contributor

    Git::SyncPracticeExercise.(exercise)

    refute_includes exercise.contributors, old_contributor
  end

  test "adds reputation token for new contributor" do
    new_contributor = create :user, github_username: 'iHiD'
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3', slug: 'bob', title: 'Bob', git_sha: '0ec511318983b7d27d6a27410509071ee7683e52', synced_to_git_sha: '0ec511318983b7d27d6a27410509071ee7683e52' # rubocop:disable Layout/LineLength

    Git::SyncPracticeExercise.(exercise)

    new_contributorship = exercise.contributorships.find_by(contributor: new_contributor)
    new_contributor_rep_token = new_contributor.reputation_tokens.last
    assert_equal :contributed_to_exercise, new_contributor_rep_token.reason
    assert_equal :authoring, new_contributor_rep_token.category
    assert_equal 10, new_contributor_rep_token.value
    assert_equal new_contributorship, new_contributor_rep_token.contributorship
  end

  test "does not add reputation token for existing contributor" do
    existing_contributor = create :user, github_username: 'iHiD'
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3', slug: 'bob', title: 'Bob', git_sha: '0ec511318983b7d27d6a27410509071ee7683e52', synced_to_git_sha: '0ec511318983b7d27d6a27410509071ee7683e52' # rubocop:disable Layout/LineLength

    existing_contributorship = create :exercise_contributorship, exercise: exercise, contributor: existing_contributor
    create :user_exercise_contribution_reputation_token, user: existing_contributor,
                                                         params: { contributorship: existing_contributorship }

    Git::SyncPracticeExercise.(exercise)

    assert_equal 1, existing_contributor.reputation_tokens.where(category: "authoring").count
  end

  test "syncs with nil prerequisites" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'Allergies', git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7", synced_to_git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7" # rubocop:disable Layout/LineLength

    git_track = Git::Track.new("HEAD", repo_url: exercise.track.repo_url)
    config = git_track.config
    config[:exercises][:practice].each { |e| e[:prerequisites] = nil }

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "syncs with nil practices" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'Allergies', git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7", synced_to_git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7" # rubocop:disable Layout/LineLength

    git_track = Git::Track.new("HEAD", repo_url: exercise.track.repo_url)
    config = git_track.config
    config[:exercises][:practice].each { |e| e[:practices] = nil }

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "handle renamed slug" do
    exercise = create :practice_exercise, uuid: '22ccca1b-7120-4db6-a736-d3d313f419c7', slug: 'retree', git_sha: "d487285d937401a676bd252015cb83ae86e4c0fe", synced_to_git_sha: "d487285d937401a676bd252015cb83ae86e4c0fe" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal 'satellite', exercise.slug
  end
end
