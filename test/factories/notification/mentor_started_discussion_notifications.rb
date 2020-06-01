FactoryBot.define do
  factory :mentor_started_discussion_notification, class: "Notification::MentorStartedDiscussionNotification" do
    user
    type { "mentor_reply" }
    params { {} }
  end
end
