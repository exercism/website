FactoryBot.define do
  factory :mentor_discussion_started_notification, class: "Notification::MentorDiscussionStartedNotification" do
    user
    type { "mentor_reply" }
    params { {} }
  end
end
