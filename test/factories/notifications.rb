FactoryBot.define do
  factory :notification, class: "Notification::MentorStartedDiscussionNotification" do
    user
    params {{
      discussion: create(:solution_mentor_discussion)
    }}
  end
end

