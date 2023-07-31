class Document::CreateSearchIndexDocument
  include Mandate

  initialize_with :doc

  def call
    {
      id: doc.id,
      title: doc.title,
      blurb: doc.blurb,
      markdown: doc.markdown,
      track: doc.track.nil? ? nil : { slug: doc.track.slug }
    }
  end
end
