FactoryBot.define do
  factory :iteration do
    solution { create :concept_solution }
  end
end
