require "test_helper"

class Git::SyncConceptTest < ActiveSupport::TestCase
  test "no change when git SHA matches HEAD SHA" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics', name: 'Basics', blurb: 'In F#, the basics are immutability and functional-first!', synced_to_git_sha: 'HEAD' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    refute concept.changed?
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics', name: 'Basics', blurb: 'In F#, the basics are immutability and functional-first!', synced_to_git_sha: 'bc30420359904725bff3c5ec9533c6f6c0a17e6e' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes in concept documents" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics', name: 'Basics', blurb: 'In F#, the basics are immutability and functional-first!', synced_to_git_sha: 'dbe79fa544e0eb2b2ba9cf03df6ac7cb3bbe7f4c' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal concept.git.head_sha, concept.synced_to_git_sha
  end

  test "concept is updated when there are changes in config.json" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics', name: 'Basics', blurb: 'The F# basics are immutability and functional-first', synced_to_git_sha: '4d67380e5a7fcc383a253b703c0bb559811ed006' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal "In F#, the basics are immutability and functional-first!", concept.blurb
  end
end
