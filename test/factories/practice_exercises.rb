FactoryBot.define do
  factory :practice_exercise do
    track { create :track, slug: 'ruby' }
    uuid { SecureRandom.uuid }
    slug { 'bob' }
    title { slug.titleize }
    git_sha { "HEAD" }

    trait :random_slug do
      slug { SecureRandom.hex }
    end
  end
end
