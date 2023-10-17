FactoryBot.define do
  factory :solution_tag, class: 'Solution::Tag' do
    tag { "paradigm:functional" }
    solution { create :practice_solution }
  end
end
