FactoryBot.define do
  factory :practice_exercise do
    track
    uuid { SecureRandom.uuid }
    slug { "practice_exercise_slug_#{SecureRandom.hex(4)}" }
    prerequisites { [] }
  end
end
