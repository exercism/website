FactoryBot.define do
  factory :scratchpad_page do
    author { create :user }
    about { create :concept_exercise }
  end
end
