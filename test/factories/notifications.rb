FactoryBot.define do
  factory :notification, class: "Notification::MentorStartedDiscussionNotification" do
    user
    params { {} }
  end
end

