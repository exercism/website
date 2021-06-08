FactoryBot.define do
  factory :notification, class: "User::Notifications::MentorStartedDiscussionNotification" do
    user
    params do
      {
        discussion: create(:mentor_discussion)
      }
    end

    trait :read do
      status { :read }
    end
    trait :unread do
      status { :unread }
    end
  end
end
