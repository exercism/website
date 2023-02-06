FactoryBot.define do
  factory :practice_solution do
    user { create :user }
    exercise { create :practice_exercise, track: }

    trait :completed do
      status { :completed }
      completed_at { Time.current }
    end

    trait :published do
      status { :published }
      published_at { Time.current }
      completed_at { Time.current - 2.minutes }
    end

    trait :downloaded do
      status { :started }
      downloaded_at { Time.current }
    end

    transient do
      track do
        Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
      end
    end

    factory :hello_world_solution do
      exercise { create :hello_world_exercise, track: }
    end
  end
end
