require 'test_helper'

class AssembleTracksForSelectTest < ActiveSupport::TestCase
  test "track" do
    track_1 = create :track
    track_2 = create :track, slug: :js
    expected = [
      SerializeTrackForSelect::ALL_TRACK,
      SerializeTrackForSelect.(track_1),
      SerializeTrackForSelect.(track_2)
    ]
    actual = AssembleTracksForSelect.()
    assert_equal expected, actual
  end
end
