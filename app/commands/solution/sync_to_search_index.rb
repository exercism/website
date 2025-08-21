class Solution::SyncToSearchIndex
  include Mandate

  queue_as :background

  initialize_with :solution

  def call
    if solution.user.ghost?
      delete_document!
    else
      create_document!
    end
  end

  private
  def create_document!
    Exercism.opensearch_client.index(
      index: Solution::OPENSEARCH_INDEX,
      id: solution.id,
      body: Solution::CreateSearchIndexDocument.(solution)
    )
    Exercism::TOUCHED_OPENSEARCH_INDEXES << Solution::OPENSEARCH_INDEX if Rails.env.test?
  end

  def delete_document!
    Exercism.opensearch_client.delete(
      index: Solution::OPENSEARCH_INDEX,
      id: solution.id
    )
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    # The record has already been deleted.
  end
end
