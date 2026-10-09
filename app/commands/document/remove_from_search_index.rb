class Document::RemoveFromSearchIndex
  include Mandate

  queue_as :default

  initialize_with :id

  def call
    Exercism.opensearch_client.delete(index: Document::OPENSEARCH_INDEX, id:)
    Exercism::TOUCHED_OPENSEARCH_INDEXES << Document::OPENSEARCH_INDEX if Rails.env.test?
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    # The document was never indexed, or has already been removed.
  end
end
