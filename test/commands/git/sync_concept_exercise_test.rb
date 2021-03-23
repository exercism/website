require "test_helper"

class Git::SyncConceptExerciseTest < ActiveSupport::TestCase
  test "git sync SHA changes to HEAD SHA when there are no changes" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", deprecated: false, git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "git SHA does not change when there are no changes" do
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    previous_head_sha = repo.head_commit.parents.first.oid
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", deprecated: false, git_sha: previous_head_sha, synced_to_git_sha: previous_head_sha # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal previous_head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .docs files" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: 'Lasagna', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .meta files" do
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    exercise = create :concept_exercise, uuid: 'd7108eb2-326c-446d-9140-228e0f220975', slug: 'numbers', title: 'Numbers', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca')
    exercise.taught_concepts << (create :track_concept, slug: 'numbers', uuid: '162721bd-3d64-43ff-889e-6fb2eac75709')
    exercise.prerequisites << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "metadata is updated when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', deprecated: true, git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    refute exercise.deprecated
  end

  test "metadata is updated when old commit is missing (e.g. due to force push)" do
    # These shas do not exist
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', deprecated: true, git_sha: "09086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "09086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    refute exercise.deprecated
  end

  test "removes taught concepts that are not in config.json" do
    conditionals_concept = create :track_concept, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca'
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: 'Lasagna', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    exercise.taught_concepts << conditionals_concept

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.taught_concepts, conditionals_concept
  end

  test "adds new taught concepts defined in config.json" do
    strings_concept = create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'
    exercise = create :concept_exercise, uuid: 'e5476046-5289-11ea-8d77-2e728ce88125', git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24", synced_to_git_sha: "e9086c7c5c9f005bbab401062fa3b2f501ecac24" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.taught_concepts, strings_concept
  end

  test "removes prerequisites that are not in config.json" do
    strings_concept = create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    exercise.prerequisites << strings_concept

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.prerequisites, strings_concept
  end

  test "adds new prerequisites defined in config.json" do
    basics_concept = create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.prerequisites, basics_concept
  end

  test "adds authors that are in .meta/config.json" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", deprecated: false, git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
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
    create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    create :track_concept, slug: 'strings', uuid: '3b1da281-7099-4c93-a109-178fc9436d68'

    Git::SyncConceptExercise.(exercise)

    refute exercise.authors.where(github_username: author.github_username).exists?
  end

  test "adds reputation token for new author" do
    new_author = create :user, github_username: "taiyab"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

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
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    existing_author_authorship = create :exercise_authorship, exercise: exercise, author: existing_author
    create :user_exercise_author_reputation_token, user: existing_author, params: { authorship: existing_author_authorship }

    Git::SyncConceptExercise.(exercise)

    assert_equal 1, existing_author.reputation_tokens.where(category: "authoring").count
  end

  test "adds contributors that are in .meta/config.json" do
    first_contributor = create :user, github_username: "kotp"
    second_contributor = create :user, github_username: "iHiD"
    third_contributor = create :user, github_username: "ErikSchierboom"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.contributors, first_contributor
    assert_includes exercise.contributors, second_contributor
    assert_includes exercise.contributors, third_contributor
  end

  test "removes contributors that are not in .meta/config.json" do
    remove_contributor = create :user, github_username: "SleeplessByte"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "0ec511318983b7d27d6a27410509071ee7683e52", synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    exercise.contributors << remove_contributor

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.contributors, remove_contributor
  end

  test "adds reputation token for new contributor" do
    new_contributor = create :user, github_username: "ErikSchierboom"
    exercise = create :concept_exercise, uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17', slug: 'booleans', title: 'Booleans', git_sha: "3fd14f32cafd9e89935bd972cecff64eb926c520", synced_to_git_sha: "3fd14f32cafd9e89935bd972cecff64eb926c520" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

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
    exercise.taught_concepts << (create :track_concept, slug: 'booleans', uuid: '831b4db4-6b75-4a8d-a835-4c2555aacb61')
    exercise.prerequisites << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')
    existing_contributorship = create :exercise_contributorship, exercise: exercise, contributor: existing_contributor
    create :user_exercise_contribution_reputation_token, user: existing_contributor,
                                                         params: { contributorship: existing_contributorship }

    Git::SyncConceptExercise.(exercise)

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
end
