FactoryBot.define do
  factory :mentor_started_discussion_notification, class: "User::Notifications::MentorStartedDiscussionNotification" do
    user
    params do
      {
        discussion: create(:solution_mentor_discussion)
      }
    end
  end
end
