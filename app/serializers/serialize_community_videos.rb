class SerializeCommunityVideos
  include Mandate

  initialize_with :videos

  def call = videos.map { |video| SerializeCommunityVideo.(video) }

  class SerializeCommunityVideo
    include Mandate

    initialize_with :video

    def call
      {
        author: video.author.present? ? SerializeAuthorOrContributor.(video.author) : nil,
        submitted_by: SerializeAuthorOrContributor.(video.submitted_by),
        platform: video.platform,
        title: video.title,
        created_at: video.created_at,
        links: {
          watch: video.url,
          embed: video.embed_url,
          channel: video.channel_url,
          thumbnail: video.thumbnail_url
        }
      }
    end
  end
end
