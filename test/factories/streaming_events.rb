FactoryBot.define do
  factory :streaming_event do
    title { SecureRandom.hex }
    description { SecureRandom.hex }
    starts_at { Time.current + 1.day }
    ends_at { starts_at + 1.hour }
    featured { false }
    youtube_id { "MyString" }
    thumbnail_url { "MyString" }

    trait :live do
      starts_at { Time.current - 30.minutes }
      ends_at { starts_at + 1.hour }
    end

    trait :past do
      starts_at { Time.current - 3.hours }
      ends_at { starts_at - 1.hour }
    end
  end
end
