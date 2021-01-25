class SerializePaginatedCollection
  include Mandate

  initialize_with :collection, :collection_serializer

  def call
    {
      results: collection_serializer.(collection),
      meta: {
        current: collection.current_page,
        total: collection.total_count
      }
    }
  end
end
