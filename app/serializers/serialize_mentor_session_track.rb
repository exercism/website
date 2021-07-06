class SerializeMentorSessionTrack
  include Mandate

  initialize_with :track

  def call
    {
      slug: track.slug,
      title: track.title,
      highlightjs_language: track.highlightjs_language,
      indent_size: track.indent_size,
      median_wait_time: track.median_wait_time,
      icon_url: track.icon_url
    }
  end
end
