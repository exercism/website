FactoryBot.define do
  factory :student_timed_out_discussion_mentor_notification,
    class: "User::Notifications::StudentTimedOutDiscussionMentorNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end
  end
end
