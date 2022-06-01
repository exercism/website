class Document::SyncAllToSearchIndex
  include Mandate

  def initialize(since: nil)
    @since = since
  end

  def call
    documents = Document.includes(:track)
    documents = documents.where("updated_at > ?", since) if since.present?

    documents.find_in_batches(batch_size: BATCH_SIZE) do |batch|
      body = batch.map do |doc|
        {
          index: {
            _index: Document::OPENSEARCH_INDEX,
            _id: doc.id,
            _type: 'document',
            data: Document::CreateSearchIndexDocument.(doc)
          }
        }
      end

      Exercism.opensearch_client.bulk(body:)
    end
  end

  private
  attr_reader :since

  BATCH_SIZE = 1000
  private_constant :BATCH_SIZE
end
