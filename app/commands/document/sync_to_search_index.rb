class Document::SyncToSearchIndex
  include Mandate

  initialize_with :document

  def call
    Exercism.opensearch_client.index(
      index: Document::OPENSEARCH_INDEX,
      type: 'document',
      id: document.id,
      body: Document::CreateSearchIndexDocument.(document)
    )
  end
end
