class Iteration::Destroy
  include Mandate

  initialize_with :iteration

  def call
    iteration.update!(deleted_at: Time.current)

    Solution::Uncomplete.(solution) unless solution.iterations.not_deleted.exists?
    Solution::Unpublish.(solution) if solution.published_iteration_id == iteration.id

    Solution::UpdateNumLoc.(solution)

    # The deleted iteration may have been the latest or published one, which
    # changes the files in the search document without changing a solution column.
    Solution::SyncToSearchIndex.defer(solution)

    # Deleting a non-pinned iteration changes what renders on the
    # published solution page without going via Unpublish
    Solution::InvalidateCloudflareCache.defer(solution)

    update_snippet!
  end

  private
  memoize
  def solution = iteration.solution

  def update_snippet!
    return unless solution.published_iterations.last

    if solution.published_iterations.last.snippet.present?
      Solution::UpdateSnippet.(solution)
    else
      Iteration::GenerateSnippet.defer(solution.published_iterations.last)
    end
  end
end
