FactoryBot.define do
  factory :joined_exercism_notification, class: "User::Notifications::JoinedExercismNotification" do
    user
  end
end
