FactoryBot.define do
  factory :joined_lifetime_premium_notification, class: "User::Notifications::JoinedLifetimePremiumNotification" do
    user
  end
end
