FactoryBot.define do
  factory :nudge_mentor_to_reply_in_discussion_notification,
    class: "User::Notifications::NudgeMentorToReplyInDiscussionNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion),
        num_days_waiting: 7
      }
    end
  end
end
