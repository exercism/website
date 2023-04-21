FactoryBot.define do
  factory :join_insiders_notification, class: "User::Notifications::JoinInsidersNotification" do
    user
  end
end
