class ReactComponents::Track::DigDeeper < ReactComponents::ReactComponent
  initialize_with :videos, :introduction, :approaches, :articles, :links, :track, :exercise

  def to_s
    super("track-dig-deeper", {
      videos: videos_data,
      approaches: approaches_data,
      articles: articles_data,
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

  def videos_data = SerializeCommunityVideos.(videos)
  def approaches_data = SerializeApproaches.(approaches)
  def articles_data = SerializeArticles.(articles)
end
