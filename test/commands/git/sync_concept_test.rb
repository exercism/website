require "test_helper"

class Git::SyncConceptTest < ActiveSupport::TestCase
  test "git sync SHA changes to HEAD SHA when there are no changes" do
    concept = create :track_concept, uuid: '3b1da281-7099-4c93-a109-178fc9436d68', slug: 'strings', name: 'Strings', blurb: 'Strings are immutable objects', synced_to_git_sha: '6487b3d27ed048552e244b416cbbb4a5e0a343e6' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes in concept documents" do
    concept = create :track_concept, uuid: '162721bd-3d64-43ff-889e-6fb2eac75709', slug: 'numbers', name: 'Numbers', blurb: 'Ruby has integers and floating-point numbers', synced_to_git_sha: '3ea5e4e99212710875a494734f77373aecada42e' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes in config.json" do
    concept = create :track_concept, uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e', slug: 'basics', name: 'Basics', blurb: 'The Ruby basics are simple', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "concept is updated when there are changes in config.json" do
    concept = create :track_concept, uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e', slug: 'basics', name: 'Basics', blurb: 'The Ruby basics are simple', synced_to_git_sha: '45c3bad984cced8a2546a204470ed9b4d80fe4ec' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal "The Ruby basics are relatively simple", concept.blurb
  end

  test "handle renamed slug" do
    concept = create :track_concept, uuid: '4dbd68ce-e736-47da-9ccd-d2ce0d8cdf1e', slug: 'class', name: 'Class', blurb: 'Strings are immutable objects', synced_to_git_sha: 'f236f73dee1558a4adcf97e14b7dc6681001c69f' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal 'classes', concept.slug
  end
end
