FactoryBot.define do
  factory :concept_exercise do
    track
    uuid { SecureRandom.uuid }
    slug { "concept_exercise_slug_#{SecureRandom.hex(4)}" }
    prerequisites { [] }
  end
end
