class SerializePaginatedCollection
  include Mandate

  initialize_with :collection, :serializer

  def call
    {
      results: collection.map { |obj| serializer.(obj) },
      meta: {
        current: collection.current_page,
        total: collection.total_count
      }
    }
  end
end
