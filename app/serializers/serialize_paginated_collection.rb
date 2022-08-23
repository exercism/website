class SerializePaginatedCollection
  include Mandate

  initialize_with :collection, data: nil,
    serializer: nil, serializer_args: [], serializer_kwargs: {},
    meta: {}

  def call
    {
      results: data || serializer_data,
      meta: {
        current_page: collection.current_page,
        total_count: collection.total_count,
        total_pages: collection.total_pages
      }.merge(meta)
    }
  end

  private
  def serializer_data
    if serializer_kwargs.present?
      serializer.(collection, *serializer_args, **serializer_kwargs)
    else
      serializer.(collection, *serializer_args)
    end
  end
end
