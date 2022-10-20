class ReactComponents::Track::Approaches < ReactComponents::ReactComponent
  initialize_with :videos, :introduction, :approaches, :links, :track, :exercise

  def to_s
    super("track-approaches", {
      videos: videos_data,
      approaches: approaches_data,
      introduction:,
      links:,
      track: track_data,
      exercise: exercise_data
    })
  end

  private
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
        author: video.author.present? ? user_data(video.author) : nil,
        submitted_by: user_data(video.submitted_by),
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

  def approaches_data
    approaches.map do |approach|
      {
        users: User::CombineAuthorsAndContributors.(approach.authors, approach.contributors).map { |user| user_data(user) },
        num_authors: approach.authors.count,
        num_contributors: approach.contributors.count,
        title: approach.title,
        blurb: approach.blurb,
        snippet: approach.snippet,
        links: {
          self: Exercism::Routes.track_exercise_approach_path(approach.track, approach.exercise, approach)
        }
      }
    end
  end

  def user_data(user)
    {
      name: user.name,
      handle: user.handle,
      avatar_url: user.avatar_url,
      links: {
        profile: user.profile? ? Exercism::Routes.profile_url(user) : nil
      }
    }
  end
end
