class Solution::RemoveUserSolutionsForTrackFromSearchIndex
  include Mandate

  queue_as :background

  initialize_with :user, :track

  def call
    Exercism.opensearch_client.delete_by_query(index: Solution::OPENSEARCH_INDEX, body: {
      query: {
        bool: {
          must: [
            { term: { 'user.id': user.id } },
            { term: { 'track.id': track.id } }
          ]
        }
      }
    })
  end
end
