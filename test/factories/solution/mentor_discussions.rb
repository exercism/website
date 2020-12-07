FactoryBot.define do
  factory :solution_mentor_discussion, class: 'Solution::MentorDiscussion' do
    mentor { create :user }
    request { create :solution_mentor_request }

    trait :requires_mentor_action do
      requires_mentor_action_since { Time.current }
    end
  end
end
