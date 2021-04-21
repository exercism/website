FactoryBot.define do
  factory :iteration do
    uuid { SecureRandom.compact_uuid }
    solution { submission.solution }
    submission
    idx { 0 }
  end
end
