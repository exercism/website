FactoryBot.define do
  factory :nudge_to_request_mentoring_notification, class: "User::Notifications::NudgeToRequestMentoringNotification" do
    user
    track { create :track }
  end
end
