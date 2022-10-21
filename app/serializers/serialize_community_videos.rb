class SerializeCommunityVideos
  include Mandate

  initialize_with :videos

  def call
    videos.includes(:author).map do |video|
      SerializeCommunityVideo.(video)
    end
  end

  class SerializeCommunityVideo
    include Mandate

    initialize_with :video

    def call
      {
        title: video.title,
        thumbnail_url: video.thumbnail_url,
        embed_url: video.embed_url,
        author: video.author.present? ? {
          name: video.author.name,
          handle: video.author.handle,
          avatar_url: video.author.avatar_url,
          links: {
            profile: Exercism::Routes.profile_url(video.author)
          }
        } : nil
      }
    end
  end
end
