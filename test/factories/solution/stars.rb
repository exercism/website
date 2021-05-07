FactoryBot.define do
  factory :solution_star, class: 'Solution::Star' do
    solution { create :practice_solution }
    user { create :user }
  end
end
