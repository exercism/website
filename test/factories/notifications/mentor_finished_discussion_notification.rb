FactoryBot.define do
  factory :mentor_finished_discussion_notification, class: "User::Notifications::MentorFinishedDiscussionNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end
  end
end
