FactoryBot.define do
  factory :notification, class: "User::Notifications::MentorStartedDiscussionNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end
  end
end
