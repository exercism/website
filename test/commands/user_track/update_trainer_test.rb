require "test_helper"

class UserTrack::UpdateTrainerTest < ActiveSupport::TestCase
  test "updates trainer status" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)

    user_track.update!(reputation: 0)
    UserTrack::UpdateTrainer.(user_track)
    refute user_track.trainer?

    user_track.update!(reputation: 49)
    UserTrack::UpdateTrainer.(user_track)
    refute user_track.trainer?

    user_track.update!(reputation: 50)
    UserTrack::UpdateTrainer.(user_track)
    assert user_track.trainer?
  end
end
