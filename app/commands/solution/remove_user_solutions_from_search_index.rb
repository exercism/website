class Solution::RemoveUserSolutionsFromSearchIndex
  include Mandate

  queue_as :background

  initialize_with :user

  def call
    Exercism.opensearch_client.delete_by_query(index: Solution::OPENSEARCH_INDEX, body: {
      query: {
        bool: {
          must: [
            { term: { 'user.id': user.id } }
          ]
        }
      }
    })
  end
end
