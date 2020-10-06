FactoryBot.define do
  factory :iteration do
    uuid { SecureRandom.compact_uuid }
    solution { create :concept_solution }
    submitted_via { "cli" }
    major { true }
  end
end
