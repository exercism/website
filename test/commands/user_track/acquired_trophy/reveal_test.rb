require "test_helper"

class UserTrack::AcquiredTrophy::RevealTest < ActiveSupport::TestCase
  test "reveals trophy" do
    user = create :user
    trophy = create :trophy
    acquired_trophy = create(:user_track_acquired_trophy, user:, trophy:)

    # Sanity check
    refute acquired_trophy.revealed?

    UserTrack::AcquiredTrophy::Reveal.(acquired_trophy)

    assert acquired_trophy.revealed?
  end

  test "clears correct notification" do
    user = create :user
    track = create :track, slug: :javascript
    trophy = create :completed_all_exercises_trophy

    bad_user = create :user
    incorrect_user = create(:user_track_acquired_trophy, user: bad_user, track:, trophy:)
    incorrect_1 = create :acquired_trophy_notification, user: bad_user, params: { user_track_acquired_trophy: incorrect_user }

    # Put this in the middle to check it's not a first/last thing.
    acquired_trophy = create(:user_track_acquired_trophy, user:, track:, trophy:)
    correct = create :acquired_trophy_notification, user:, params: { user_track_acquired_trophy: acquired_trophy }

    incorrect_track = create(:user_track_acquired_trophy, user:, trophy:)
    incorrect_2 = create :acquired_trophy_notification, user:, params: { user_track_acquired_trophy: incorrect_track }

    incorrect_trophy = create(:user_track_acquired_trophy, user:, track:)
    incorrect_3 = create :acquired_trophy_notification, user:, params: { user_track_acquired_trophy: incorrect_trophy }

    UserTrack::AcquiredTrophy::Reveal.(acquired_trophy)
    p acquired_trophy.user_id

    refute incorrect_1.reload.read?
    refute incorrect_2.reload.read?
    refute incorrect_3.reload.read?
    assert correct.reload.read?
  end
end
