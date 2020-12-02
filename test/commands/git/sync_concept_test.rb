require "test_helper"

class Git::SyncConceptTest < ActiveSupport::TestCase
  test "no change when git SHA matches HEAD SHA" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics!', name: 'Basics!', synced_to_git_sha: 'a1bd9f34c324e35f87f6d9f0115da79eb4176642' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    refute concept.changed?
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f', slug: 'conditionals', name: 'Conditionals', synced_to_git_sha: 'c68f057eb4cfc3f9d07867e9ee9e29de7bfac088' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes in concept documents" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics', name: 'Basics', synced_to_git_sha: '434ffe503a51531c8e1c6f5d7d10275afa69497a' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "concept is updated when there are changes in config.json" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics', name: 'Basics', blurb: 'The F# basics are immutability and functional-first', synced_to_git_sha: 'c68f057eb4cfc3f9d07867e9ee9e29de7bfac088' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal "the-basics", concept.slug
    assert_equal "The Basics", concept.name
    assert_equal "The F# basics are immutability and functional-first!", concept.blurb
  end
end
