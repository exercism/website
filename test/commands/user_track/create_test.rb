require "test_helper"

class UserTrack::CreateTest < ActiveSupport::TestCase
  test "creates user_track" do
    user = create :user
    track = create :track

    UserTrack::Create.(user, track)

    assert_equal 1, UserTrack.count
    ut = UserTrack.last

    assert_equal user, ut.user
    assert_equal track, ut.track
  end

  test "idempotent" do
    user = create :user
    track = create :track

    assert_idempotent_command { UserTrack::Create.(user, track) }
  end
end
