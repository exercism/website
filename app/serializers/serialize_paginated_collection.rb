class SerializePaginatedCollection
  include Mandate

  def initialize(
    collection,
    data: nil,
    serializer: nil, serializer_args: [], serializer_kwargs: {},
    meta: {}
  )
    @collection = collection
    @data = data
    @serializer = serializer
    @serializer_args = serializer_args
    @serializer_kwargs = serializer_kwargs
    @meta = meta
  end

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
  attr_reader :collection, :serializer, :serializer_args, :serializer_kwargs, :data, :meta

  def serializer_data
    if serializer_kwargs.present?
      serializer.(collection, *serializer_args, **kserializer_kwargs)
    else
      serializer.(collection, *serializer_args)
    end
  end
end
