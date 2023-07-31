class SerializeDoc
  include Mandate

  initialize_with :doc

  def call
    {
      uuid: doc.uuid,
      title: doc.title,
      blurb: doc.blurb,
      track: doc.track.present? ? {
        slug: doc.track.slug,
        title: doc.track.title,
        icon_url: doc.track.icon_url
      } : nil,
      updated_at: doc.updated_at.iso8601,
      links: {
        self: Exercism::Routes.doc_url(doc.section, doc.slug)
      }
    }
  end
end
