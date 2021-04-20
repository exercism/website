FactoryBot.define do
  factory :mentor_replied_to_discussion_notification, class: "User::Notifications::MentorRepliedToDiscussionNotification" do
    user
    params do
      {
        discussion_post: create(:mentor_discussion_post)
      }
    end
  end
end
