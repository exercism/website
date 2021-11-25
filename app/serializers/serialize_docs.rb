class SerializeDocs
  include Mandate

  initialize_with :docs

  def call
    docs.map { |doc| SerializeDoc.(doc) }
  end
end
