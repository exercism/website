require "test_helper"

class Git::SyncConceptExerciseTest < ActiveSupport::TestCase
  test "respects force_sync: true" do
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", git_sha: repo.head_commit.oid, synced_to_git_sha: repo.head_commit.oid # rubocop:disable Layout/LineLength

    Git::SyncExerciseAuthors.expects(:call).never
    Git::SyncConceptExercise.(exercise)

    Git::SyncExerciseAuthors.expects(:call).once
    Git::SyncConceptExercise.(exercise, force_sync: true)
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "git SHA does not change when there are no changes" do
    updated_at = Time.current - 1.week
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
    previous_head_sha = repo.head_commit.parents.first.oid
    exercise = create(:concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", position: 3, git_sha: previous_head_sha, synced_to_git_sha: previous_head_sha, updated_at:) # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal previous_head_sha, exercise.git_sha
    assert_equal updated_at, exercise.reload.updated_at
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    freeze_time do
      exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", updated_at: Time.current - 1.week # rubocop:disable Layout/LineLength
      create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
      create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

      Git::SyncConceptExercise.(exercise)

      assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
      assert_equal exercise.git.head_sha, exercise.git_sha
      assert_equal Time.current, exercise.reload.updated_at
    end
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .docs files" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: 'Lasagna', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .meta files" do
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    exercise = create :concept_exercise, uuid: 'd7108eb2-326c-446d-9140-228e0f220975', slug: 'numbers', title: 'Numbers', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca')
    exercise.taught_concepts << (create :concept, slug: 'numbers', uuid: '162721bd-3d64-43ff-889e-6fb2eac75709')
    exercise.prerequisites << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in important files" do
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "7a8bd1bbeb0d54a08c39d84d59cc7a8ed54d45aa", synced_to_git_sha: "7a8bd1bbeb0d54a08c39d84d59cc7a8ed54d45aa" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "metadata is updated when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', status: :deprecated, git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    assert_equal 'Like puppets on a...', exercise.reload.blurb
  end

  test "metadata is updated when old commit is missing (e.g. due to force push)" do
    # These shas do not exist
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', status: :deprecated, git_sha: "09086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "09086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    assert_equal 'Like puppets on a...', exercise.reload.blurb
  end

  test "status is updated when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: 'd7108eb2-326c-446d-9140-228e0f220975', status: :beta, slug: 'numbers', title: 'Numbers', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca')
    exercise.taught_concepts << (create :concept, slug: 'numbers', uuid: '162721bd-3d64-43ff-889e-6fb2eac75709')
    exercise.prerequisites << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')

    Git::SyncConceptExercise.(exercise)

    assert_equal :wip, exercise.status
  end

  test "status is active when no explicit status is specified" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: 'Lasagna', git_sha: "8143313785d71541efb0d9f188c306e9ec75327f", synced_to_git_sha: "8143313785d71541efb0d9f188c306e9ec75327f" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal :active, exercise.status
  end

  test "position is updated when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', position: 2, status: :deprecated, git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    assert_equal 6, exercise.position
  end

  test "icon_name is updated when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: 'f4f7de13-a9ee-4251-8796-006ed85b3f70', icon_name: 'chopping', git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    assert_equal 'logs', exercise.icon_name
  end

  test "has_test_runner is updated when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', has_test_runner: false, status: :deprecated, git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    assert exercise.has_test_runner?
  end

  test "removes taught concepts that are not in config.json" do
    conditionals_concept = create :concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca'
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: 'Lasagna', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    exercise.taught_concepts << conditionals_concept

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.taught_concepts, conditionals_concept
  end

  test "adds new taught concepts defined in config.json" do
    strings_concept = create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.taught_concepts, strings_concept
  end

  test "removes prerequisites that are not in config.json" do
    strings_concept = create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    exercise.prerequisites << strings_concept

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.prerequisites, strings_concept
  end

  test "removes prerequisites that are not taught by any concept exercise" do
    strings = create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'
    types = create :concept, slug: 'types', uuid: '3f1168b5-fc74-4586-94f5-20e4f60e52cf'
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    exercise.prerequisites << strings
    exercise.prerequisites << types

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.prerequisites, types
  end

  test "adds new prerequisites defined in config.json" do
    basics_concept = create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.prerequisites, basics_concept
  end

  test "adds authors that are in .meta/config.json" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    first_author = create :user, github_username: "iHiD"
    second_author = create :user, github_username: "pvcarrera"

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.authors, first_author
    assert_includes exercise.authors, second_author
  end

  test "removes authors that are not in .meta/config.json" do
    author = create :user, github_username: "ErikSchierboom"
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    exercise.authors << author
    create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    refute exercise.authors.with_data.where(data: { github_username: author.github_username }).exists?
  end

  test "adds reputation token for new author" do
    new_author = create :user, github_username: "taiyab"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    perform_enqueued_jobs do
      Git::SyncConceptExercise.(exercise)
    end

    new_authorship = exercise.authorships.find_by(author: new_author)
    new_author_rep_token = new_author.reputation_tokens.last
    assert_equal :authoring, new_author_rep_token.category
    assert_equal :authored_exercise, new_author_rep_token.reason
    assert_equal 20, new_author_rep_token.value
    assert_equal new_authorship, new_author_rep_token.authorship
  end

  test "does not add reputation token for existing author" do
    existing_author = create :user, github_username: "neenjaw"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    existing_author_authorship = create :exercise_authorship, exercise:, author: existing_author
    create :user_exercise_author_reputation_token, user: existing_author, params: { authorship: existing_author_authorship }

    perform_enqueued_jobs do
      Git::SyncConceptExercise.(exercise)
    end

    assert_equal 1, existing_author.reputation_tokens.where(category: "authoring").count
  end

  test "adds contributors that are in .meta/config.json" do
    first_contributor = create :user, github_username: "kotp"
    second_contributor = create :user, github_username: "iHiD"
    third_contributor = create :user, github_username: "ErikSchierboom"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.contributors, first_contributor
    assert_includes exercise.contributors, second_contributor
    assert_includes exercise.contributors, third_contributor
  end

  test "removes contributors that are not in .meta/config.json" do
    remove_contributor = create :user, github_username: "SleeplessByte"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    exercise.contributors << remove_contributor

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.contributors, remove_contributor
  end

  test "adds reputation token for new contributor" do
    new_contributor = create :user, github_username: "ErikSchierboom"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "3fd14f32cafd9e89935bd972cecff64eb926c520", synced_to_git_sha: "3fd14f32cafd9e89935bd972cecff64eb926c520" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    perform_enqueued_jobs do
      Git::SyncConceptExercise.(exercise)
    end

    new_contributorship = exercise.contributorships.find_by(contributor: new_contributor)
    new_contributor_rep_token = new_contributor.reputation_tokens.last
    assert_equal :contributed_to_exercise, new_contributor_rep_token.reason
    assert_equal :authoring, new_contributor_rep_token.category
    assert_equal 10, new_contributor_rep_token.value
    assert_equal new_contributorship, new_contributor_rep_token.contributorship
  end

  test "does not add reputation token for existing contributor" do
    existing_contributor = create :user, github_username: "kotp"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "3fd14f32cafd9e89935bd972cecff64eb926c520", synced_to_git_sha: "3fd14f32cafd9e89935bd972cecff64eb926c520" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    existing_contributorship = create :exercise_contributorship, exercise:, contributor: existing_contributor
    create :user_exercise_contribution_reputation_token, user: existing_contributor,
      params: { contributorship: existing_contributorship }

    perform_enqueued_jobs do
      Git::SyncConceptExercise.(exercise)
    end

    assert_equal 1, existing_contributor.reputation_tokens.where(category: "authoring").count
  end

  test "syncs with nil prerequisites" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: 'Lasagna', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength

    git_track = Git::Track.new("HEAD", repo_url: exercise.track.repo_url)
    config = git_track.config
    config[:exercises][:concept].each { |e| e[:prerequisites] = nil }

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncConceptExercise.(exercise)
  end

  test "syncs with nil concepts" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: 'Lasagna', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength

    git_track = Git::Track.new("HEAD", repo_url: exercise.track.repo_url)
    config = git_track.config
    config[:exercises][:concept].each { |e| e[:concepts] = nil }

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "handle renamed slug" do
    exercise = create :concept_exercise, uuid: 'f4f7de13-a9ee-4251-8796-006ed85b3f70', slug: 'logs', git_sha: "c75486b75db8012646b0e1c667cb1db47ff5a9d5", synced_to_git_sha: "c75486b75db8012646b0e1c667cb1db47ff5a9d5" # rubocop:disable Layout/LineLength
    create :concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    assert_equal 'log-levels', exercise.slug
  end

  test "updates site_update" do
    exercise = create :concept_exercise, uuid: 'f4f7de13-a9ee-4251-8796-006ed85b3f70', slug: 'logs', git_sha: "3c693834d59dbcaab3dde474a8c6b2c5d747f0f2", synced_to_git_sha: "3c693834d59dbcaab3dde474a8c6b2c5d747f0f2" # rubocop:disable Layout/LineLength
    SiteUpdates::ProcessNewExerciseUpdate.expects(:call).with(exercise)

    Git::SyncConceptExercise.(exercise, force_sync: true)
  end

  test "updates has_approaches" do
    exercise = create :concept_exercise, uuid: 'f4f7de13-a9ee-4251-8796-006ed85b3f70', slug: 'logs'
    Exercise::UpdateHasApproaches.expects(:call).with(exercise)

    Git::SyncConceptExercise.(exercise, force_sync: true)
  end

  test "syncs introduction authors" do
    author = create :user, github_username: 'erikschierboom'
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125'

    # Sanity check
    assert_empty exercise.approach_introduction_authors

    Git::SyncConceptExercise.(exercise, force_sync: true)

    assert_equal [author], exercise.reload.approach_introduction_authors
  end

  test "syncs introduction contributors" do
    contributor = create :user, github_username: 'ihid'
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125'

    # Sanity check
    assert_empty exercise.approach_introduction_contributors

    Git::SyncConceptExercise.(exercise, force_sync: true)

    assert_equal [contributor], exercise.reload.approach_introduction_contributors
  end
end
