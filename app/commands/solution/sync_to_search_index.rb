class Solution::SyncToSearchIndex
  include Mandate

  initialize_with :solution

  def call
    return
    Exercism.opensearch_client.index(
      index: Solution::OPENSEARCH_INDEX,
      type: 'solution',
      id: solution.id,
      body: Solution::CreateSearchIndexDocument.(solution)
    )
  end
end
