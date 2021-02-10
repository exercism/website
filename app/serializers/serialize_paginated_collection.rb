class SerializePaginatedCollection
  include Mandate

  def initialize(collection, collection_serializer, meta: {})
    @collection = collection
    @collection_serializer = collection_serializer
    @meta = meta
  end

  def call
    {
      results: collection_serializer.(collection),
      meta: {
        current_page: collection.current_page,
        total_count: collection.total_count,
        total_pages: collection.total_pages
      }.merge(meta)
    }
  end

  private
  attr_reader :collection, :collection_serializer, :meta
end
