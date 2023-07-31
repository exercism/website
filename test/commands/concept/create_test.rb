require "test_helper"

class Concept::CreateTest < ActiveSupport::TestCase
  test "creates concept" do
    uuid = SecureRandom.uuid
    track = create :track

    Concept::Create.(
      uuid,
      track,
      slug: 'conditionals',
      name: 'Conditionals',
      blurb: 'Conditionally executing logic',
      synced_to_git_sha: 'HEAD'
    )

    assert_equal 1, Concept.count
    c = Concept.last

    assert_equal uuid, c.uuid
    assert_equal track, c.track
    assert_equal 'conditionals', c.slug
    assert_equal 'Conditionals', c.name
    assert_equal 'Conditionally executing logic', c.blurb
    assert_equal 'HEAD', c.synced_to_git_sha
  end

  test "idempotent" do
    uuid = SecureRandom.uuid
    track = create :track

    assert_idempotent_command do
      Concept::Create.(
        uuid,
        track,
        slug: 'conditionals',
        name: 'Conditionals',
        blurb: 'Conditionally executing logic',
        synced_to_git_sha: 'HEAD'
      )
    end

    assert_equal 1, SiteUpdate.count
  end

  test "creates site_update" do
    track = create :track
    concept = Concept::Create.(
      SecureRandom.uuid,
      track,
      **build(:concept).attributes.symbolize_keys
    )

    update = SiteUpdate.first
    assert_equal concept, update.concept
    assert_equal track, update.track
  end
end
