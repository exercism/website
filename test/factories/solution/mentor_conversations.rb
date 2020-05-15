FactoryBot.define do
  factory :solution_mentor_conversation, class: 'Solution::MentorConversation' do
    mentor { create :user }
    request { create :solution_mentor_request }
  end
end
