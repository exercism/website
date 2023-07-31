require "test_helper"

class CommunityVideo::RetrieveFromYoutubeTest < ActiveSupport::TestCase
  test "gets the data" do
    url = "https://www.youtube.com/watch?v=hFZFjoX2cGg&ab_channel=MarkRober"
    key = ENV.fetch('GOOGLE_API_KEY', Exercism.secrets.google_api_key)

    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=hFZFjoX2cGg&part=snippet&key=#{key}").
      to_return(status: 200, body: SUCCESSFUL_RESPONSE, headers: {})

    video = CommunityVideo::RetrieveFromYoutube.(url)
    assert_equal "Backyard Squirrel Maze 1.0- Ninja Warrior Course", video.title
    assert_equal url, video.url
    assert_equal :youtube, video.platform
    assert_equal "hFZFjoX2cGg", video.watch_id
    assert_equal "hFZFjoX2cGg", video.embed_id
    assert_equal "Mark Rober", video.channel_name
    assert_equal "https://www.youtube.com/channel/UCY1kMZp36IQSyNx_9h4mpCg", video.channel_url
    assert_equal "https://www.youtube-nocookie.com/embed/hFZFjoX2cGg", video.embed_url
    assert_equal "https://i.ytimg.com/vi/hFZFjoX2cGg/sddefault.jpg", video.thumbnail_url
    assert_equal Time.utc(2020, 5, 24, 16, 0, 58), video.published_at
  end

  test "fallback to smaller thumbnail urls" do
    url = "https://www.youtube.com/watch?v=hFZFjoX2cGg&ab_channel=MarkRober"
    key = ENV.fetch('GOOGLE_API_KEY', Exercism.secrets.google_api_key)

    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=hFZFjoX2cGg&part=snippet&key=#{key}").
      to_return(status: 200, body: SMALL_THUMBNAIL_RESPONSE, headers: {})

    video = CommunityVideo::RetrieveFromYoutube.(url)
    assert_equal "https://i.ytimg.com/vi/hFZFjoX2cGg/sddefault.jpg", video.thumbnail_url
  end

  SUCCESSFUL_RESPONSE = %q(
    {
      "items": [
        {
          "snippet": {
            "publishedAt": "2020-05-24T16:00:58Z",
            "channelId": "UCY1kMZp36IQSyNx_9h4mpCg",
            "title": "Backyard Squirrel Maze 1.0- Ninja Warrior Course",
            "description": "Squirrels were stealing my bird seed so I've solved the problem...",
            "thumbnails": {
              "standard": {
                "url": "https://i.ytimg.com/vi/hFZFjoX2cGg/sddefault.jpg",
                "width": 640,
                "height": 480
              }
            },
            "channelTitle": "Mark Rober"
          }
        }
      ],
      "pageInfo": {
        "totalResults": 1,
        "resultsPerPage": 1
      }
    }
  ).freeze

  SMALL_THUMBNAIL_RESPONSE = %q(
    {
      "items": [
        {
          "snippet": {
            "publishedAt": "2020-05-24T16:00:58Z",
            "channelId": "UCY1kMZp36IQSyNx_9h4mpCg",
            "title": "Backyard Squirrel Maze 1.0- Ninja Warrior Course",
            "description": "Squirrels were stealing my bird seed so I've solved the problem...",
            "thumbnails": {
              "high": {
                "url": "https://i.ytimg.com/vi/hFZFjoX2cGg/sddefault.jpg",
                "width": 640,
                "height": 480
              }
            },
            "channelTitle": "Mark Rober"
          }
        }
      ],
      "pageInfo": {
        "totalResults": 1,
        "resultsPerPage": 1
      }
    }
  ).freeze
end
