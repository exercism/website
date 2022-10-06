FactoryBot.define do
  factory :community_video do
    submitted_by { create :user }

    url { "https://youtube.com/watch?v=me" }
    embed_url { "https://youtube.com/embed/me" }
    platform { :youtube }
    title { "something interesting" }
    thumbnail_url { "http://the.internet.com" }
    channel_url { "https://youtube.com/watch/abcdefg" }
    channel_name { "a cool place for squirrels" }
    watch_id { "me-them" }
    embed_id { "me&them" }
  end
end
