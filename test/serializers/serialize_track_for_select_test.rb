require 'test_helper'

class SerializeTrackForSelectTest < ActiveSupport::TestCase
  test "track" do
    track = create :track
    expected = {
      slug: track.slug,
      title: track.title,
      icon_url: track.icon_url
    }
    assert_equal expected, SerializeTrackForSelect.(track)
  end

  test "all" do
    expected = {
      slug: nil,
      title: "All Tracks",
      icon_url: nil
    }
    assert_equal expected, SerializeTrackForSelect::ALL_TRACK
  end
end
