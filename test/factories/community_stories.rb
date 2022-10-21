FactoryBot.define do
  factory :community_story do
    interviewer { create :user }
    interviewee { create :user }
    uuid { SecureRandom.uuid }
    slug { "dont-be-productive" }
    title { "Don't be productive" }
    blurb { "Try not to be productive" }
    published_at { Time.current - 1.minute }
    thumbnail_url { "http://example.org/thumbnail.png" }
    image_url { "http://example.org/image.png" }
    length_in_minutes { 60 }
    youtube_id { "the-youtu.be-id" }

    trait :random do
      slug { "slug-#{SecureRandom.uuid}" }
    end
  end
end
