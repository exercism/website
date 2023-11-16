require "test_helper"

class UserTrack::UpdateTrainerTest < ActiveSupport::TestCase
  test "updates trainer status" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:, reputation: 77)

    UserTrack::UpdateTrainer.(user_track, true)
    assert user_track.trainer?

    UserTrack::UpdateTrainer.(user_track, false)
    refute user_track.trainer?
  end

  test "raises when trying to enable trainer whilst not meeting requirements" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:, reputation: 12)

    assert_raises TrainerCriteriaNotFulfilledError do
      UserTrack::UpdateTrainer.(user_track, true)
    end

    # Sanity check: disabling is always allowed
    UserTrack::UpdateTrainer.(user_track, false)
  end
end
