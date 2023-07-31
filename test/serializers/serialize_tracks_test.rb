require 'test_helper'

class SerializeTracksTest < ActiveSupport::TestCase
  test "sorts by name" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript", slug: :js
    assembly = create :track, title: "Assembly", slug: :ass
    rust = create :track, title: "Rust", slug: :rust

    expected = %w[Assembly Javascript Ruby Rust]
    actual = SerializeTracks.(
      [ruby, javascript, assembly, rust],
      nil
    ).map { |t| t[:title] }
    assert_equal expected, actual
  end

  test "sorts by joined then name" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript", slug: :js
    assembly = create :track, title: "Assembly", slug: :ass
    rust = create :track, title: "Rust", slug: :rust

    user = create :user
    create :user_track, user:, track: rust

    expected = %w[Rust Assembly Javascript Ruby]
    actual = SerializeTracks.(
      [ruby, javascript, assembly, rust],
      user
    ).map { |t| t[:title] }
    assert_equal expected, actual
  end

  test "doesn't use n+1 notification checks" do
    user = create :user
    track_1 = create :track, title: "A"
    user_track_1 = create :user_track, user:, track: track_1

    track_2 = create :track, :random_slug, title: "B"
    user_track_2 = create :user_track, user:, track: track_2

    # Create notification and check it matches this track
    # (which it does because of clever factories)
    create :notification, user:, status: :unread
    assert user_track_1.has_notifications?
    refute user_track_2.has_notifications?

    # Sanity check the individual serializer uses it
    UserTrack.any_instance.expects(:has_notifications?).twice
    SerializeTrack.(track_1, user_track_1)
    SerializeTrack.(track_2, user_track_2)

    UserTrack.any_instance.expects(:has_notifications?).never
    data = SerializeTracks.(Track.all, user)
    assert data[0][:has_notifications]
    refute data[1][:has_notifications]
  end
end
