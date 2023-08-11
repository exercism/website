FactoryBot.define do
  factory :expired_insiders_notification, class: "User::Notifications::ExpiredInsidersNotification" do
    user
  end
end
