class ReactComponents::Track::Approaches < ReactComponents::ReactComponent
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
        author: if video.author.present?
                  {
                    name: video.author.name,
                    handle: video.author.handle,
                    avatar_url: video.author.avatar_url,
                    links: {
                      profile: video.author.profile? ? Exercism::Routes.profile_url(video.author) : nil
                    }
                  }
                end,
        submitted_by: {
          name: video.submitted_by.name,
          handle: video.submitted_by.handle,
          avatar_url: video.submitted_by.avatar_url,
          links: {
            profile: video.submitted_by.profile? ? Exercism::Routes.profile_url(video.submitted_by) : nil
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
