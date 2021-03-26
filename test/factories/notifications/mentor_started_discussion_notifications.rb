FactoryBot.define do
  factory :mentor_started_discussion_notification, class: "User::Notifications::MentorStartedDiscussionNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end
  end
end
