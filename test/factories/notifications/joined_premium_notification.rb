FactoryBot.define do
  factory :joined_premium_notification, class: "User::Notifications::JoinedPremiumNotification" do
    user
  end
end
