module ReactComponents
  module Track
    class Approaches < ReactComponent
      initialize_with :videos, :introduction, :approaches, :links, :track, :exercise
      def to_s
        super("track-approaches", {
          videos: videos_data,
          introduction:,
          links:,
          track: track_data,
          exercise: exercise_data
        })
      end

      def track_data
        {
          icon_url: track.icon_url,
          title: track.title,
          slug: track.slug
        }
      end

      def exercise_data
        {
          icon_url: exercise.icon_url,
          title: exercise.title,
          slug: exercise.slug
        }
      end

      def videos_data
        videos.map do |video|
          {
            author: video.author.present? ? {
              name: video.author.name,
              handle: video.author.handle,
              avatar_url: video.author.avatar_url,
              links: {
                profile: Exercism::Routes.profile_url(video.author)
              }
            } : nil,
            submitted_by: {
              name: video.submitted_by.name,
              handle: video.submitted_by.handle,
              avatar_url: video.submitted_by.avatar_url,
              links: {
                profile: Exercism::Routes.profile_url(video.submitted_by)
              }
            },
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
  end
end
