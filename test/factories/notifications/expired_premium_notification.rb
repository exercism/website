FactoryBot.define do
  factory :expired_premium_notification, class: "User::Notifications::ExpiredPremiumNotification" do
    user
  end
end
