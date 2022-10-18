FactoryBot.define do
  factory :exercise_approach, class: 'Exercise::Approach' do
    exercise { create :practice_exercise }
    uuid { SecureRandom.uuid }
    slug { 'performance' }
    blurb { "Learn all about #{slug}" }
    title { slug.to_s.titleize }
    synced_to_git_sha { "HEAD" }

    trait :random do
      slug { SecureRandom.hex }
    end
  end
end
