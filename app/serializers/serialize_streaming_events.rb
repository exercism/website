class SerializeStreamingEvents
  include Mandate

  initialize_with :events

  def call = events.map { |event| SerializeStreamingEvent.(event) }

  class SerializeStreamingEvent
    include Mandate

    initialize_with :event

    def call
      {
        id: event.id,
        title: event.title,
        description: event.description,
        starts_at: event.starts_at,
        ends_at: event.ends_at,
        featured: event.featured?,
        thumbnail_url: event.thumbnail_url,
        links: {
          watch: event.youtube_external_url,
          embed: event.youtube_embed_url
        }
      }
    end
  end
end
