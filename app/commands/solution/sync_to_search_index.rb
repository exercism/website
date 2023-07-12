class Solution::SyncToSearchIndex
  include Mandate

  queue_as :background

  initialize_with :solution

  def call
    # p solution.id
    # p Solution::CreateSearchIndexDocument.(solution)

    Exercism.opensearch_client.index(
      index: Solution::OPENSEARCH_INDEX,
      type: 'solution',
      id: solution.id,
      body: Solution::CreateSearchIndexDocument.(solution)
    )
  end
end
