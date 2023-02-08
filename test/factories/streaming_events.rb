FactoryBot.define do
  factory :streaming_event do
    title { "MyString" }
    description { "MyText" }
    starts_at { "2023-02-08" }
    ends_at { "2023-02-08" }
    featured { false }
    youtube_id { "MyString" }
    thumbnail_url { "MyString" }
  end
end
