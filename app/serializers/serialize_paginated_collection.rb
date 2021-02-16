class SerializePaginatedCollection
  include Mandate

  def initialize(collection, data: nil, serializer: nil, meta: {})
    @collection = collection
    @data = data
    @serializer = serializer
    @meta = meta
  end

  def call
    {
      results: data || serializer.(collection),
      meta: {
        current_page: collection.current_page,
        total_count: collection.total_count,
        total_pages: collection.total_pages
      }.merge(meta)
    }
  end

  private
  attr_reader :collection, :serializer, :data, :meta
end
