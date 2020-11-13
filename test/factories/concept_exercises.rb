FactoryBot.define do
  factory :concept_exercise do
    track { create :track, slug: 'csharp' }
    uuid { SecureRandom.uuid }
    slug { 'datetime' }
    title { slug.titleize }

    trait :random_slug do
      slug { SecureRandom.hex }
    end
  end
end
