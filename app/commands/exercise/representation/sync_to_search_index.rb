class Exercise::Representation::SyncToSearchIndex
  include Mandate

  queue_as :background

  initialize_with :representation

  def call
    return unless representation
    return if exercise.tutorial?

    if representation.num_published_solutions.zero?
      delete_document!
    else
      create_document!
    end
  rescue NoPublishedSolutionForRepresentationError
    delete_document!
  end

  private
  delegate :exercise, to: :representation

  def create_document!
    Exercism.opensearch_client.index(
      index: Exercise::Representation::OPENSEARCH_INDEX,
      id: representation.id,
      body: Exercise::Representation::CreateSearchIndexDocument.(representation)
    )
  end

  def delete_document!
    Exercism.opensearch_client.delete(
      index: Exercise::Representation::OPENSEARCH_INDEX,
      id: representation.id
    )
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    # The record has already been deleted.
  end
end
