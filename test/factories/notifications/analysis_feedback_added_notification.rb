FactoryBot.define do
  factory :analysis_feedback_added_notification, class: "User::Notifications::AnalysisFeedbackAddedNotification" do
    user
    params do
      {
        representation: create(:exercise_representation, user:),
        iteration: create(:iteration, user:)
      }
    end
  end
end
