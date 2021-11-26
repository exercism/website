class Document::SyncToSearchIndex
  include Mandate

  initialize_with :doc

  def call
    Exercism.opensearch_client.index(
      index: Document::OPENSEARCH_INDEX,
      type: 'document',
      id: doc.id,
      body: Document::CreateSearchIndexDocument.(doc)
    )
  end
end
