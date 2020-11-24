require "test_helper"

class Git::SyncConceptTest < ActiveSupport::TestCase
  test "no change when concept matches config.json" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics!', name: 'Basics!' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    refute concept.changed?
  end

  test "concept is updated when there are changes in config.json" do
    track = create :track, slug: 'fsharp'
    concept = create :track_concept, track: track, uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215', slug: 'basics', name: 'Basics' # rubocop:disable Layout/LineLength

    Git::SyncConcept.(concept)

    assert_equal "basics!", concept.slug
    assert_equal "Basics!", concept.name
  end
end
