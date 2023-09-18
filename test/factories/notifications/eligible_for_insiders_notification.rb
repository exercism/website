FactoryBot.define do
  factory :eligible_for_insiders_notification, class: "User::Notifications::EligibleForInsidersNotification" do
    user
  end
end
