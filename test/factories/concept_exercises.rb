FactoryBot.define do
  factory :concept_exercise do
    track do
      Track.find_by(slug: :csharp) || build(:track, slug: 'csharp')
    end
    uuid { SecureRandom.uuid }
    slug { 'strings' }
    title { slug.titleize }
    git_sha { "HEAD" }
    synced_to_git_sha { "HEAD" }

    trait :random_slug do
      slug { SecureRandom.hex }
    end
  end
end
