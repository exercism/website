FactoryBot.define do
  factory :analysis_feedback_added_notification, class: "User::Notifications::AnalysisFeedbackAddedNotification" do
    user
    params do
      {
        representation: create(:exercise_representation),
        iteration: create(:iteration, user:)
      }
    end
  end
end
