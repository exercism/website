FactoryBot.define do
  factory :acquired_badge_notification, class: "User::Notifications::AcquiredBadgeNotification" do
    user
    params do
      {
        user_acquired_badge: create(:user_acquired_badge, user:)
      }
    end
  end
end
