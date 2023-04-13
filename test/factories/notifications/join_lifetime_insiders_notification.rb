FactoryBot.define do
  factory :join_lifetime_insiders_notification, class: "User::Notifications::JoinLifetimeInsidersNotification" do
    user
  end
end
