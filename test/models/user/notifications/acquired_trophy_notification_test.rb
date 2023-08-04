require 'test_helper'

class User::Notifications::AcquiredTrophyNotificationTest < ActiveSupport::TestCase
  include Propshaft::Helper

  test "keys are valid" do
    user = create :user
    track = create :track
    trophy = create :trophy
    user_track_acquired_trophy = create(:user_track_acquired_trophy, user:, track:, trophy:)

    notification = User::Notifications::AcquiredTrophyNotification.create!(user:, params: { user_track_acquired_trophy: })
    assert_equal "#{user.id}|acquired_trophy|Track##{track.id}|Trophy##{trophy.id}", notification.uniqueness_key
  end
end
