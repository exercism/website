class Solution::RemoveUserSolutionsForTrackFromSearchIndex
  include Mandate

  queue_as :background

  initialize_with :user_track

  def call
    Exercism.opensearch_client.delete_by_query(index: Solution::OPENSEARCH_INDEX, body: {
      query: {
        bool: {
          must: [
            { term: { 'user.id': user_track.user_id } },
            { term: { 'track.id': user_track.track_id } }
          ]
        }
      }
    })
  end
end
