class Document::CreateSearchIndexDocument
  include Mandate

  initialize_with :doc

  def call
    {
      id: doc.id,
      title: doc.title,
      blurb: doc.blurb,
      content_html: doc.content_html,
      updated_at: doc.updated_at,
      track: doc.track.nil? ? nil : {
        id: doc.track.id,
        slug: doc.track.slug,
        title: doc.track.title
      }
    }
  end
end
