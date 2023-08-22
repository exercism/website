FactoryBot.define do
  factory :acquired_trophy_notification, class: "User::Notifications::AcquiredTrophyNotification" do
    user
    params do
      {
        user_track_acquired_trophy: create(:user_track_acquired_trophy, user:)
      }
    end
  end
end
