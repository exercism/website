require 'test_helper'

class SerializeTracksTest < ActiveSupport::TestCase
  test "sorts by name" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript", slug: :js
    assembly = create :track, title: "Assembly", slug: :ass
    rust = create :track, title: "Rust", slug: :rust

    expected = %w[Assembly Javascript Ruby Rust]
    actual = SerializeTracks.(
      [ruby, javascript, assembly, rust]
    ).map { |t| t[:title] }
    assert_equal expected, actual
  end

  test "sorts by joined then name" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript", slug: :js
    assembly = create :track, title: "Assembly", slug: :ass
    rust = create :track, title: "Rust", slug: :rust

    user = create :user
    create :user_track, user: user, track: rust

    expected = %w[Rust Assembly Javascript Ruby]
    actual = SerializeTracks.(
      [ruby, javascript, assembly, rust],
      user
    ).map { |t| t[:title] }
    assert_equal expected, actual
  end

  test "doesn't use n+1 notification checks" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track

    # Create notification and check it matches this track
    # (which it does because of clever factories)
    create :notification, user: user
    assert user_track.has_notifications?

    # Sanity check the individual serializer uses it
    UserTrack.any_instance.expects(:has_notifications?).once
    SerializeTrack.(track, user_track)

    UserTrack.any_instance.expects(:has_notifications?).never
    data = SerializeTracks.(Track.all, user)
    assert data[0][:has_notifications]
  end
end
