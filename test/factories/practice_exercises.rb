FactoryBot.define do
  factory :practice_exercise do
    track
    uuid { SecureRandom.uuid }
    slug { :bob }
    title { "Bob" }
  end
end
