FactoryBot.define do
  factory :concept_exercise do
    track
    uuid { SecureRandom.uuid }
    slug { :bob }
  end
end
