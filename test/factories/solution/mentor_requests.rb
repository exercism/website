FactoryBot.define do
  factory :solution_mentor_request, class: 'Solution::MentorRequest' do
    solution { create :practice_solution }
    type { :code_review }
    comment { "I could do with some help here" }
    bounty { 1 }
  end
end
