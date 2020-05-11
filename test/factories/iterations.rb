FactoryBot.define do
  factory :iteration do
    uuid { SecureRandom.compact_uuid }
    solution { create :concept_solution }
  end
end
