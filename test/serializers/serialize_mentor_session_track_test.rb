require 'test_helper'

class SerializeMentorSessionTrackTest < ActiveSupport::TestCase
  test "serializes" do
    track = create :track

    expected = {
      slug: track.slug,
      title: track.title,
      highlightjs_language: track.highlightjs_language,
      indent_size: track.indent_size,
      median_wait_time: track.median_wait_time,
      icon_url: track.icon_url
    }

    assert_equal expected, SerializeMentorSessionTrack.(track)
  end
end
