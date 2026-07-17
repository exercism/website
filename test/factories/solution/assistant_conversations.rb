FactoryBot.define do
  factory :solution_assistant_conversation, class: 'Solution::AssistantConversation' do
    solution { create :concept_solution }
    user { solution.user }
    messages { [] }
  end
end
