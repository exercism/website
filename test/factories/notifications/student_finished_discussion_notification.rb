FactoryBot.define do
  factory :student_finished_discussion_notification,
    class: "User::Notifications::StudentFinishedDiscussionNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end
  end
end
