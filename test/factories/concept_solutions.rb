FactoryBot.define do
  factory :concept_solution do
    user { create :user }
    exercise { create :concept_exercise }
  end
end
