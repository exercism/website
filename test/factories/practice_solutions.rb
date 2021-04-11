FactoryBot.define do
  factory :practice_solution do
    user { create :user }
    exercise { create :practice_exercise, track: track }

    trait :completed do
      completed_at { Time.current }
    end

    trait :published do
      published_at { Time.current }
    end

    transient do
      track do
        Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
      end
    end

    factory :hello_world_solution do
      exercise { create :hello_world_exercise, track: track }
    end
  end
end
