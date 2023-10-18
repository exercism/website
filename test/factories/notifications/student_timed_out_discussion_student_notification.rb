FactoryBot.define do
  factory :student_timed_out_discussion_student_notification,
    class: "User::Notifications::StudentTimedOutDiscussionStudentNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end
  end
end
