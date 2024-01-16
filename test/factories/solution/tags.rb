FactoryBot.define do
  factory :solution_tag, class: 'Solution::Tag' do
    tag { "paradigm:functional" }
    solution { create :practice_solution }
    exercise { solution.exercise }
    track { solution.track }
  end
end
