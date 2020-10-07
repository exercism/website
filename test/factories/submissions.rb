FactoryBot.define do
  factory :submission do
    uuid { SecureRandom.compact_uuid }
    solution { create :concept_solution }
    submitted_via { "cli" }
    major { true }
  end
end
