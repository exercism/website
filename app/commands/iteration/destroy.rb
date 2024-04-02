class Iteration::Destroy
  include Mandate

  initialize_with :iteration

  def call
    iteration.update!(deleted_at: Time.current)

    Solution::Uncomplete.(solution) unless solution.iterations.not_deleted.exists?
    Solution::Unpublish.(solution) if solution.published_iteration_id == iteration.id

    Solution::UpdateNumLoc.(solution)

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
