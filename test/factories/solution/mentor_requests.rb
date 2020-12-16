FactoryBot.define do
  factory :solution_mentor_request, class: 'Solution::MentorRequest' do
    solution { create :practice_solution }
    type { :code_review }
    comment { "I could do with some help here" }

    trait :locked do
      locked_until { Time.current + 30.minutes }
      locked_by { create :user }
    end
  end
end
