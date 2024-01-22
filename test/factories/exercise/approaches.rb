FactoryBot.define do
  factory :exercise_approach, class: 'Exercise::Approach' do
    track do
      Track.find_by(slug: 'ruby') || build(:track, slug: 'ruby')
    end
    exercise { create :practice_exercise, slug: 'hamming', track: }
    uuid { SecureRandom.uuid }
    slug { 'readability' }
    blurb { "Learn all about #{slug}" }
    title { slug.to_s.titleize }
    synced_to_git_sha { "HEAD" }
    position { 1 }

    trait :random do
      slug { SecureRandom.hex }
    end
  end
end
