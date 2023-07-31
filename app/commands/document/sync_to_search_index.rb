class Document::SyncToSearchIndex
  include Mandate

  queue_as :default

  initialize_with :doc

  def call
    Exercism.opensearch_client.index(
      index: Document::OPENSEARCH_INDEX,
      id: doc.id,
      body: Document::CreateSearchIndexDocument.(doc)
    )
  end
end
