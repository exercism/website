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
        current: collection.current_page,
        total: collection.total_count
      }.merge(meta)
    }
  end

  private
  attr_reader :collection, :collection_serializer, :meta
end
