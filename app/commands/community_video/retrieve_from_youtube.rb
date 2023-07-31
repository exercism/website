# Sample URL
# https://www.youtube.com/watch?v=hFZFjoX2cGg&ab_channel=MarkRober
class CommunityVideo::RetrieveFromYoutube
  include Mandate

  initialize_with :url

  def call
    CommunityVideo.new(
      url:,
      embed_url:,
      platform: :youtube,

      title: snippet["title"],
      watch_id: youtube_id,
      embed_id: youtube_id,

      channel_name: snippet["channelTitle"],
      channel_url: "https://www.youtube.com/channel/#{snippet['channelId']}",

      thumbnail_url:,

      published_at: DateTime.parse(snippet['publishedAt'])
    )
  rescue StandardError
    raise InvalidCommunityVideoUrlError
  end

  def embed_url = "https://www.youtube-nocookie.com/embed/#{youtube_id}"

  memoize
  def snippet
    resp = JSON.parse(RestClient.get(api_url).body)

    items = resp['items']
    raise InvalidCommunityVideoUrlError if items.blank?

    items.first['snippet']
  end

  memoize
  def youtube_id
    params = URI(url).query.split("&").map { |qp| qp.split("=") }.to_h
    params["v"]
  end

  def thumbnail_url
    %w[standard high medium default].each do |size|
      return snippet["thumbnails"][size]["url"] if snippet["thumbnails"][size]
    end
  end

  memoize
  def api_url
    api_key = ENV.fetch('GOOGLE_API_KEY', Exercism.secrets.google_api_key)
    "https://www.googleapis.com/youtube/v3/videos?id=#{youtube_id}&part=snippet&key=#{api_key}"
  end
end
