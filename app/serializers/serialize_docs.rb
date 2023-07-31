class SerializeDocs
  include Mandate

  initialize_with :docs

  def call
    eager_loaded_docs.map { |doc| SerializeDoc.(doc) }
  end

  private
  def eager_loaded_docs
    docs.to_active_relation.
      includes(:track)
  end
end
