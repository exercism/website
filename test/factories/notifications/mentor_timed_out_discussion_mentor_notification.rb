FactoryBot.define do
  factory :mentor_timed_out_discussion_mentor_notification,
    class: "User::Notifications::MentorTimedOutDiscussionMentorNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end
  end
end
