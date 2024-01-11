require "test_helper"

class Git::SyncConceptTest < ActiveSupport::TestCase
  test "respects force_sync: true" do
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
    concept = create :concept, uuid: '3b1da281-7099-4c93-a109-178fc9436d68', slug: 'strings', name: 'Strings', blurb: 'Strings are immutable objects', synced_to_git_sha: repo.head_commit.oid # rubocop:disable Layout/LineLength

    Git::SyncConceptAuthors.expects(:call).never
    Git::SyncConcept.(concept)

    Git::SyncConceptAuthors.expects(:call).once
    Git::SyncConcept.(concept, force_sync: true)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    concept = create :concept, uuid: '3b1da281-7099-4c93-a109-178fc9436d68', slug: 'strings', name: 'Strings', blurb: 'Strings are immutable objects', synced_to_git_sha: '6487b3d27ed048552e244b416cbbb4a5e0a343e6' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes in concept documents" do
    concept = create :concept, uuid: '162721bd-3d64-43ff-889e-6fb2eac75709', slug: 'numbers', name: 'Numbers', blurb: 'Ruby has integers and floating-point numbers', synced_to_git_sha: '3ea5e4e99212710875a494734f77373aecada42e' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes in config.json" do
    concept = create :concept, uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e', slug: 'basics', name: 'Basics', blurb: 'The Ruby basics are simple', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "concept is updated when there are changes in config.json" do
    concept = create :concept, uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca', slug: 'conditionals', name: 'Conditional logic', blurb: 'With if and unless you can conditionally execute code', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal "Conditionals", concept.name
  end

  test "concept is updated when there are changes in .meta/config.json" do
    concept = create :concept, uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca', slug: 'conditionals', name: 'Conditional logic', blurb: 'Conditionals blurb', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal "With if and unless you can conditionally execute code", concept.blurb
  end

  test "handle renamed slug" do
    concept = create :concept, uuid: '4dbd68ce-e736-47da-9ccd-d2ce0d8cdf1e', slug: 'class', name: 'Class', blurb: 'Strings are immutable objects', synced_to_git_sha: 'f236f73dee1558a4adcf97e14b7dc6681001c69f' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal 'classes', concept.slug
  end

  test "adds authors that are in .meta/config.json" do
    concept = create :concept, uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength
    first_author = create :user, github_username: 'ErikSchierboom'
    second_author = create :user, github_username: 'iHiD'

    Git::SyncConcept.(concept)

    assert_equal 2, concept.authors.size
    assert_includes concept.authors, first_author
    assert_includes concept.authors, second_author
  end

  test "removes authors that are not in .meta/config.json" do
    concept = create :concept, uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength
    old_author = create :user, github_username: 'DJ'
    concept.authors << old_author

    Git::SyncConcept.(concept)

    refute concept.authors.with_data.where(data: { github_username: old_author.github_username }).exists?
  end

  test "adds reputation token for new author" do
    concept = create :concept, uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength
    new_author = create :user, github_username: 'ErikSchierboom'

    perform_enqueued_jobs do
      Git::SyncConcept.(concept)
    end

    new_authorship = concept.authorships.find_by(author: new_author)
    new_author_rep_token = new_author.reputation_tokens.last
    assert_equal :authoring, new_author_rep_token.category
    assert_equal :authored_concept, new_author_rep_token.reason
    assert_equal 10, new_author_rep_token.value
    assert_equal new_authorship, new_author_rep_token.authorship
  end

  test "does not add reputation token for existing author" do
    concept = create :concept, uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength
    existing_author = create :user, github_username: 'ErikSchierboom'

    existing_concept_authorship = create :concept_authorship, concept:, author: existing_author
    create :user_concept_author_reputation_token, user: existing_author, params: { authorship: existing_concept_authorship }

    perform_enqueued_jobs do
      Git::SyncConcept.(concept)
    end

    assert_equal 1, existing_author.reputation_tokens.where(category: "authoring").count
  end

  test "adds contributors that are in .meta/config.json" do
    contributor = create :user, github_username: 'iHiD'
    concept = create :concept, uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal 1, concept.contributors.size
    assert_includes concept.contributors, contributor
  end

  test "removes contributors that are not in .meta/config.json" do
    old_contributor = create :user, github_username: "ErikSchierboom"
    concept = create :concept, uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength
    concept.contributors << old_contributor

    Git::SyncConcept.(concept)

    refute_includes concept.contributors, old_contributor
  end

  test "adds reputation token for new contributor" do
    new_contributor = create :user, github_username: 'iHiD'
    concept = create :concept, uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength

    perform_enqueued_jobs do
      Git::SyncConcept.(concept)
    end

    new_contributorship = concept.contributorships.find_by(contributor: new_contributor)
    new_contributor_rep_token = new_contributor.reputation_tokens.last
    assert_equal :contributed_to_concept, new_contributor_rep_token.reason
    assert_equal :authoring, new_contributor_rep_token.category
    assert_equal 5, new_contributor_rep_token.value
    assert_equal new_contributorship, new_contributor_rep_token.contributorship
  end

  test "does not add reputation token for existing contributor" do
    existing_contributor = create :user, github_username: 'iHiD'
    concept = create :concept, uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength

    existing_contributorship = create :concept_contributorship, concept:, contributor: existing_contributor
    create :user_concept_contribution_reputation_token, user: existing_contributor,
      params: { contributorship: existing_contributorship }

    perform_enqueued_jobs do
      Git::SyncConcept.(concept)
    end

    assert_equal 1, existing_contributor.reputation_tokens.where(category: "authoring").count
  end
end
