class AssembleDocs
  include Mandate

  initialize_with :params

  def call
    SerializePaginatedCollection.(docs, serializer: SerializeDocs)
  end

  memoize
  def docs
    Document::SearchDocs.(
      criteria: params[:criteria],
      track_slug: params[:track_slug],
      page: params[:page],
      per: params[:per_page]
    )
  end
end
