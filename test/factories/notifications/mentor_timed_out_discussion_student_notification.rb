FactoryBot.define do
  factory :mentor_timed_out_discussion_student_notification,
    class: "User::Notifications::MentorTimedOutDiscussionStudentNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end
  end
end
