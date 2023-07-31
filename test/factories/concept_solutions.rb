FactoryBot.define do
  factory :concept_solution do
    user { create :user }
    exercise { create :concept_exercise, track: }

    trait :completed do
      completed_at { Time.current }
      status { :completed }
    end

    trait :published do
      completed_at { Time.current - 2.minutes }
      published_at { Time.current }
      status { :published }
    end

    transient do
      track do
        Track.find_by(slug: 'ruby') || create(:track, slug: 'ruby')
      end
    end
  end
end
