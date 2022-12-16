require "test_helper"

class Track::UpdateRepresenterVersionTest < ActiveSupport::TestCase
  test "updates representer version" do
    track = create :track, representer_version: 1

    Track::UpdateRepresenterVersion.(track)

    assert_equal 2, track.representer_version
  end
end
