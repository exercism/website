FactoryBot.define do
  factory :student_replied_to_discussion_notification,
    class: "User::Notifications::StudentRepliedToDiscussionNotification" do
    user
    params do
      {
        discussion_post: create(:mentor_discussion_post)
      }
    end
  end
end
