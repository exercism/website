FactoryBot.define do
  factory :exercise_article, class: 'Exercise::Article' do
    exercise { create :practice_exercise, slug: 'hamming' }
    uuid { SecureRandom.uuid }
    slug { 'performance' }
    blurb { "Learn all about #{slug}" }
    title { slug.to_s.titleize }
    synced_to_git_sha { "HEAD" }
    position { 1 }

    trait :random do
      slug { SecureRandom.hex }
    end
  end
end
