FactoryBot.define do
  factory :joined_lifetime_insiders_notification, class: "User::Notifications::JoinedLifetimeInsidersNotification" do
    user
  end
end
