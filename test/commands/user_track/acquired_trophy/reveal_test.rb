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
end
