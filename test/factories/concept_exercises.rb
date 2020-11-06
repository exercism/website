FactoryBot.define do
  factory :concept_exercise do
    track { create :track, slug: 'csharp' }
    uuid { SecureRandom.uuid }
    slug { 'datetime' }
    title { slug.titleize }
  end
end
