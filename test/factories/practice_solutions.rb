FactoryBot.define do
  factory :practice_solution do
    user { create :user }
    exercise { create :practice_exercise }
  end
end
