FactoryBot.define do
  factory :practice_exercise do
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end

    uuid { SecureRandom.uuid }
    slug { 'bob' }
    title { slug.titleize }
    git_sha { "HEAD" }
    synced_to_git_sha { "HEAD" }

    trait :random_slug do
      slug { SecureRandom.hex }
    end
  end
end
