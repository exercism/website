require "test_helper"

class CommunityVideo::RetrieveFromYoutubeTest < ActiveSupport::TestCase
  test "gets the data" do
    url = "https://www.youtube.com/watch?v=hFZFjoX2cGg&ab_channel=MarkRober"

    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=hFZFjoX2cGg&part=snippet&key=#{Exercism.secrets.google_api_key}").
      to_return(status: 200, body: SUCCESSFUL_RESPONSE, headers: {})

    video = CommunityVideo::RetrieveFromYoutube.(url)
    assert_equal "Backyard Squirrel Maze 1.0- Ninja Warrior Course", video.title
    assert_equal url, video.url
    assert_equal :youtube, video.platform
    assert_equal "hFZFjoX2cGg", video.watch_id
    assert_equal "hFZFjoX2cGg", video.embed_id
    assert_equal "Mark Rober", video.channel_name
    assert_equal "https://www.youtube.com/channel/UCY1kMZp36IQSyNx_9h4mpCg", video.channel_url
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
end
