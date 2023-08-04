FactoryBot.define do
  factory :acquired_trophy_notification, class: "User::Notifications::AcquiredTrophyNotification" do
    user
    track
    trophy
    params do
      {
        user_track_acquired_trophy: create(:user_track_acquired_trophy, user:, track:, trophy:)
      }
    end
  end
end
