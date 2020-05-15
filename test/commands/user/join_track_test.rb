require "test_helper"

class User::JoinTrackTest < ActiveSupport::TestCase
  test "creates user_track" do
    user = create :user
    track = create :track

    User::JoinTrack.(user, track)

    assert_equal 1, UserTrack.count
    ut = UserTrack.last

    assert_equal user, ut.user
    assert_equal track, ut.track
  end
end
