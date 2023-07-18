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
      type: 'solution',
      id: solution.id,
      body: Solution::CreateSearchIndexDocument.(solution)
    )
  end

  def delete_document!
    Exercism.opensearch_client.delete(
      index: Solution::OPENSEARCH_INDEX,
      type: 'solution',
      id: solution.id
    )
  end
end
