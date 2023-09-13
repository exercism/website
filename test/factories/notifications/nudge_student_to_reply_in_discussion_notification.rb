FactoryBot.define do
  factory :nudge_student_to_reply_in_discussion_notification,
    class: "User::Notifications::NudgeStudentToReplyInDiscussionNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion, awaiting_student_since: Time.current - 7.days),
        num_days_waiting: 7
      }
    end
  end
end
