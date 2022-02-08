class Iteration
  class Destroy
    include Mandate

    initialize_with :iteration

    def call
      iteration.update!(deleted_at: Time.current)

      Solution::Uncomplete.(solution) unless solution.iterations.not_deleted.exists?
      Solution::Unpublish.(solution) if solution.published_iteration_id == iteration.id
    end

    private
    memoize
    def solution
      iteration.solution
    end
  end
end
