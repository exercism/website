class SerializeCommunityVideos
  include Mandate

  initialize_with :videos

  def call
    videos.includes(author: :profile, submitted_by: :profile).map do |video|
      SerializeCommunityVideo.(video)
    end
  end

  class SerializeCommunityVideo
    include Mandate

    initialize_with :video

    def call
      {
        id: video.id,
        title: video.title,
        thumbnail_url: video.thumbnail_url,
        embed_url: video.embed_url,
        author: video.author.present? ? SerializeAuthorOrContributor.(video.author) : nil,
        submitted_by: SerializeAuthorOrContributor.(video.submitted_by),
        platform: video.platform,
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
