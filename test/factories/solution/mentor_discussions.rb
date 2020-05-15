FactoryBot.define do
  factory :solution_mentor_discussion, class: 'Solution::MentorDiscussion' do
    mentor { create :user }
    request { create :solution_mentor_request }
  end
end
