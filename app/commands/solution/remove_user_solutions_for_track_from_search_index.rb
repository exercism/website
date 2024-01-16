class Solution::RemoveUserSolutionsForTrackFromSearchIndex
  include Mandate

  queue_as :background

  # Use ids here as we're calling this because either the
  # user or the track has been deleted, so we can't retrieve
  # the record from the database
  initialize_with :user_id, :track_id

  def call
    Exercism.opensearch_client.delete_by_query(index: Solution::OPENSEARCH_INDEX, body: {
      query: {
        bool: {
          must: [
            { term: { 'user.id': user_id } },
            { term: { 'track.id': track_id } }
          ]
        }
      }
    })
  rescue OpenSearch::Transport::Transport::Errors::Conflict
    raise if @retries.to_i >= 3

    sleep(0.5)
    @retries = @retries.to_i + 1
    retry
  end
end
