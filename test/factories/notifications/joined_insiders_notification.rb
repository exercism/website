FactoryBot.define do
  factory :joined_insiders_notification, class: "User::Notifications::JoinedInsidersNotification" do
    user
  end
end
