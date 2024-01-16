require "test_helper"

class Git::SyncPracticeExerciseTest < ActiveSupport::TestCase
  test "respects force_sync: true" do
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'Allergies', git_sha: repo.head_commit.oid, synced_to_git_sha: repo.head_commit.oid # rubocop:disable Layout/LineLength

    Git::SyncExerciseAuthors.expects(:call).never
    Git::SyncPracticeExercise.(exercise)

    Git::SyncExerciseAuthors.expects(:call).once
    Git::SyncPracticeExercise.(exercise, force_sync: true)
  end

  test "only git sync SHA changes to HEAD SHA when there are no changes" do
    skip # TODO: find better way to setup this test
    updated_at = Time.current - 1.week
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
    git_sha = repo.head_commit.parents.first.oid
    strings = create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'
    exercise = create(:practice_exercise, uuid: 'd5644b3c-5d48-4d31-b208-b6365b10c0db', slug: 'anagram', title: 'Anagram', position: 9, difficulty: 7, git_sha:, synced_to_git_sha: git_sha, updated_at:) # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca')
    exercise.prerequisites << strings
    exercise.practiced_concepts << strings

    assert_equal updated_at, exercise.reload.updated_at # Sanity

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal git_sha, exercise.git_sha
    assert_equal updated_at, exercise.reload.updated_at
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    freeze_time do
      exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'Allergies', git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7", synced_to_git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7", updated_at: Time.current - 1.week # rubocop:disable Layout/LineLength
      exercise.prerequisites << (create :concept, slug: 'arrays', uuid: '55b8bfe8-4c8c-460b-ab78-b3f384b6f313')

      Git::SyncPracticeExercise.(exercise)

      assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
      assert_equal exercise.git.head_sha, exercise.git_sha
      assert_equal Time.current, exercise.reload.updated_at
    end
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in important files" do
    exercise = create :practice_exercise, uuid: 'a8b33d2e-d4f7-4162-acf8-44f75f9b1988', slug: 'tournament', title: 'Tournament', git_sha: "23fc26dad93968db3da774cbcc3fc8bb929762c7", synced_to_git_sha: "23fc26dad93968db3da774cbcc3fc8bb929762c7" # rubocop:disable Layout/LineLength

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    exercise = create :practice_exercise, uuid: '53603e05-2051-4904-a181-e358390f9ae7', slug: 'hamming', title: 'hamming', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "metadata is updated when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'Allergies', git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7", synced_to_git_sha: "88f22a83588c87881a5da994b3984b400fb43bd7" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'arrays', uuid: '55b8bfe8-4c8c-460b-ab78-b3f384b6f313')

    Git::SyncPracticeExercise.(exercise)

    assert_equal "Allergies Alert", exercise.title
    assert_equal "Allergic? Try this!", exercise.blurb
  end

  test "difficulty is updated when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: 'd5644b3c-5d48-4d31-b208-b6365b10c0db', difficulty: 5, slug: 'anagram', title: 'Anagram', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal 2, exercise.difficulty
  end

  test "has_test_runner is updated when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: 'd5644b3c-5d48-4d31-b208-b6365b10c0db', has_test_runner: false, slug: 'anagram', title: 'Anagram', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert exercise.has_test_runner?
  end

  test "icon_name is updated when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: '782d71b7-7ed8-4b5b-89b8-8f0ec10f81a8', icon_name: 'going-iso', slug: 'isogram', title: 'Isogram', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal 'iso', exercise.icon_name
  end

  test "status is updated when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: 'd5644b3c-5d48-4d31-b208-b6365b10c0db', status: :active, slug: 'anagram', title: 'Anagram', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal :beta, exercise.status
  end

  test "status is active when no explicit status is specified" do
    exercise = create :practice_exercise, uuid: '53603e05-2051-4904-a181-e358390f9ae7', position: 1, slug: 'hamming', title: 'hamming', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal :active, exercise.status
  end

  test "position is updated when there are changes in config.json" do
    exercise = create :practice_exercise, uuid: '53603e05-2051-4904-a181-e358390f9ae7', position: 1, slug: 'hamming', title: 'hamming', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal 10, exercise.position
  end

  test "position is always 0 for hello-world exercise" do
    exercise = create :practice_exercise, uuid: '33adf9eb-fbf4-4100-a9bb-2f334b9ee72f', position: 1, slug: 'hello-world', title: 'Hello World', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal 0, exercise.position
  end

  test "adds new prerequisites defined in config.json" do
    exercise = create :practice_exercise, uuid: '4f12ede3-312e-482a-b0ae-dfd29f10b5fb', slug: 'leap', title: 'Leap', git_sha: "e84f87c9c527a2bbeb72e8013d32114809f1bee9", synced_to_git_sha: "e84f87c9c527a2bbeb72e8013d32114809f1bee9" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'numbers', uuid: '162721bd-3d64-43ff-889e-6fb2eac75709')
    conditionals = create :concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca'

    Git::SyncPracticeExercise.(exercise)

    assert_includes exercise.prerequisites, conditionals
  end

  test "removes prerequisites that are not in config.json" do
    time = create :concept, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    exercise = create :practice_exercise, uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206', slug: 'space-age', title: 'Space Age', git_sha: "503834363624c44f1202953427e7047f0472cbe7", synced_to_git_sha: "503834363624c44f1202953427e7047f0472cbe7" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a')
    exercise.prerequisites << time

    Git::SyncPracticeExercise.(exercise)

    refute_includes exercise.prerequisites, time
  end

  test "removes prerequisites that are not taught by any concept exercise" do
    time = create :concept, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    types = create :concept, slug: 'types', uuid: '3f1168b5-fc74-4586-94f5-20e4f60e52cf'
    exercise = create :practice_exercise, uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206', slug: 'space-age', title: 'Space Age', git_sha: "503834363624c44f1202953427e7047f0472cbe7", synced_to_git_sha: "503834363624c44f1202953427e7047f0472cbe7" # rubocop:disable Layout/LineLength
    exercise.prerequisites << (create :concept, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a')
    exercise.prerequisites << time
    exercise.prerequisites << types

    Git::SyncPracticeExercise.(exercise)

    refute_includes exercise.prerequisites, types
  end

  test "adds new practiced concepts defined in config.json" do
    time = create :concept, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    dates = create :concept, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a'
    exercise = create :practice_exercise, uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206', slug: 'space-age', title: 'Space Age', git_sha: "503834363624c44f1202953427e7047f0472cbe7", synced_to_git_sha: "503834363624c44f1202953427e7047f0472cbe7" # rubocop:disable Layout/LineLength

    Git::SyncPracticeExercise.(exercise)

    assert_equal 2, exercise.practiced_concepts.size
    assert_includes exercise.practiced_concepts, dates
    assert_includes exercise.practiced_concepts, time
  end

  test "removes practiced concepts that are not in config.json" do
    time = create :concept, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    dates = create :concept, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a'
    conditionals = create :concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca'
    exercise = create :practice_exercise, uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206', slug: 'space-age', title: 'Space Age', git_sha: "503834363624c44f1202953427e7047f0472cbe7", synced_to_git_sha: "503834363624c44f1202953427e7047f0472cbe7" # rubocop:disable Layout/LineLength
    exercise.practiced_concepts << dates
    exercise.practiced_concepts << time
    exercise.practiced_concepts << conditionals

    Git::SyncPracticeExercise.(exercise)

    assert_equal 2, exercise.practiced_concepts.size
    assert_includes exercise.practiced_concepts, dates
    assert_includes exercise.practiced_concepts, time
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

    refute exercise.authors.with_data.where(data: { github_username: old_author.github_username }).exists?
  end

  test "adds reputation token for new author" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a', slug: 'allergies', title: 'allergies', git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a', synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a' # rubocop:disable Layout/LineLength
    new_author = create :user, github_username: 'ErikSchierboom'

    perform_enqueued_jobs do
      Git::SyncPracticeExercise.(exercise)
    end

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

    existing_author_authorship = create :exercise_authorship, exercise:, author: existing_author
    create :user_exercise_author_reputation_token, user: existing_author, params: { authorship: existing_author_authorship }

    perform_enqueued_jobs do
      Git::SyncPracticeExercise.(exercise)
    end

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

    perform_enqueued_jobs do
      Git::SyncPracticeExercise.(exercise)
    end

    new_contributorship = exercise.contributorships.find_by(contributor: new_contributor)
    new_contributor_rep_token = User::ReputationTokens::ExerciseContributionToken.where(user: new_contributor).last
    assert_equal :contributed_to_exercise, new_contributor_rep_token.reason
    assert_equal :authoring, new_contributor_rep_token.category
    assert_equal 10, new_contributor_rep_token.value
    assert_equal new_contributorship, new_contributor_rep_token.contributorship
  end

  test "does not add reputation token for existing contributor" do
    existing_contributor = create :user, github_username: 'iHiD'
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3', slug: 'bob', title: 'Bob', git_sha: '0ec511318983b7d27d6a27410509071ee7683e52', synced_to_git_sha: '0ec511318983b7d27d6a27410509071ee7683e52' # rubocop:disable Layout/LineLength

    existing_contributorship = create :exercise_contributorship, exercise:, contributor: existing_contributor
    create :user_exercise_contribution_reputation_token, user: existing_contributor,
      params: { contributorship: existing_contributorship }

    perform_enqueued_jobs do
      Git::SyncPracticeExercise.(exercise)
    end

    assert_equal 1, User::ReputationTokens::ExerciseContributionToken.where(user: existing_contributor).count
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
    exercise.prerequisites << (create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68')

    Git::SyncPracticeExercise.(exercise)

    assert_equal 'satellite', exercise.slug
  end

  test "syncs test runner" do
    exercise = create :practice_exercise, has_test_runner: false, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a'

    Git::SyncPracticeExercise.(exercise, force_sync: true)

    assert exercise.reload.has_test_runner?
  end

  test "updates site_update" do
    exercise = create :practice_exercise, uuid: '185b964c-1ec1-4d60-b9b9-fa20b9f57b4a'
    SiteUpdates::ProcessNewExerciseUpdate.expects(:call).with(exercise)

    Git::SyncPracticeExercise.(exercise, force_sync: true)
  end

  test "updates has_approaches" do
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3'
    Exercise::UpdateHasApproaches.expects(:call).with(exercise)

    Git::SyncPracticeExercise.(exercise, force_sync: true)
  end

  test "updates representer_version" do
    exercise = create :practice_exercise, uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206'

    Git::SyncPracticeExercise.(exercise, force_sync: true)

    assert_equal 2, exercise.representer_version
  end

  test "syncs introduction authors" do
    author = create :user, github_username: 'erikschierboom'
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3'

    # Sanity check
    assert_empty exercise.approach_introduction_authors

    Git::SyncPracticeExercise.(exercise, force_sync: true)

    assert_equal [author], exercise.reload.approach_introduction_authors
  end

  test "syncs introduction contributors" do
    contributor_1 = create :user, github_username: 'ihid'
    contributor_2 = create :user, github_username: 'jane'
    exercise = create :practice_exercise, uuid: '70fec82e-3038-468f-96ef-bfb48ce03ef3'

    # Sanity check
    assert_empty exercise.approach_introduction_contributors

    Git::SyncPracticeExercise.(exercise, force_sync: true)

    assert_equal [contributor_1, contributor_2], exercise.reload.approach_introduction_contributors
  end

  test "syncs approaches" do
    user_1 = create :user, github_username: 'erikschierboom'
    user_2 = create :user, github_username: 'ihid'
    exercise = create :practice_exercise, uuid: '53603e05-2051-4904-a181-e358390f9ae7', slug: 'hamming'

    # Sanity check
    assert_empty exercise.approaches

    create(:exercise_approach, exercise:)
    assert_equal 1, exercise.reload.approaches.count

    Git::SyncPracticeExercise.(exercise, force_sync: true)

    assert_equal 2, exercise.reload.approaches.count

    approach_1 = exercise.approaches.first
    assert_equal "23360676-7b7f-4759-b6b6-011ef8f9c420", approach_1.uuid
    assert_equal "functional", approach_1.slug
    assert_equal "Functional", approach_1.title
    assert_equal "All those functions", approach_1.blurb
    assert_equal [user_1], approach_1.authors
    assert_equal [user_2], approach_1.contributors

    approach_2 = exercise.approaches.second
    assert_equal "954be92c-a79e-4ed6-bd0f-f4db3c09a668", approach_2.uuid
    assert_equal "readability", approach_2.slug
    assert_equal "Readability", approach_2.title
    assert_equal "This reads well!", approach_2.blurb
    assert_equal [user_1, user_2], approach_2.authors
    assert_empty approach_2.contributors
  end

  test "syncs articles" do
    user_1 = create :user, github_username: 'erikschierboom'
    user_2 = create :user, github_username: 'ihid'
    exercise = create :practice_exercise, uuid: '53603e05-2051-4904-a181-e358390f9ae7', slug: 'hamming'

    # Sanity check
    assert_empty exercise.articles

    create(:exercise_article, exercise:)
    assert_equal 1, exercise.reload.articles.count

    Git::SyncPracticeExercise.(exercise, force_sync: true)

    assert_equal 1, exercise.reload.articles.count

    article = exercise.articles.first
    assert_equal "7feff49c-32ea-4d30-b6da-002b51e0f57d", article.uuid
    assert_equal "performance", article.slug
    assert_equal "Performance", article.title
    assert_equal "Check out this perf!", article.blurb
    assert_equal [user_1], article.authors
    assert_equal [user_2], article.contributors
  end
end
