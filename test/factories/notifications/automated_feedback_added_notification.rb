FactoryBot.define do
  factory :automated_feedback_added_notification, class: "User::Notifications::AutomatedFeedbackAddedNotification" do
    user
    params do
      {
        representation: create(:exercise_representation),
        iteration: create(:iteration, user:)
      }
    end
  end
end
