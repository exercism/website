require "test_helper"

class UserTrack::UpdateReputationTest < ActiveSupport::TestCase
  test "update reputation" do
    user = create :user
    other_user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    user_track = create(:user_track, user:, track:, reputation: 0)
    user_track_other_track = create(:user_track, user:, track: other_track, reputation: 11)
    user_track_other_user = create(:user_track, user: other_user, track:, reputation: 33)

    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 20, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 18, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 30, arbitrary_reason: "" }

    # Sanity check: ignore reputation for same user but other track
    create :user_arbitrary_reputation_token, user:, track: other_track, params: { arbitrary_value: 9, arbitrary_reason: "" }

    # Sanity check: ignore reputation for same track but different user
    create :user_arbitrary_reputation_token, user: other_user, track:, params: { arbitrary_value: 7, arbitrary_reason: "" }

    UserTrack::UpdateReputation.(user_track)

    assert_equal 20 + 18 + 30, user_track.reload.reputation
    assert_equal 11, user_track_other_track.reload.reputation
    assert_equal 33, user_track_other_user.reload.reputation
  end
end
