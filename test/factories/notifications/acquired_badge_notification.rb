FactoryBot.define do
  factory :acquired_badge_notification, class: "User::Notifications::AcquiredBadgeNotification" do
    user
    version { 1 }
    params do
      {
        badge: create(:rookie_badge)
      }
    end
  end
end
