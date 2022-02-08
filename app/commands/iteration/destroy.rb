class Iteration
  class Destroy
    include Mandate

    initialize_with :iteration

    def call
      iteration.update!(deleted_at: Time.current)

      if !solution.iterations.not_deleted.exists?
        Solution::Uncomplete.(solution)
      elsif solution.published_iteration_id == iteration.id
        Solution::Unpublish.(solution)
      end
    end

    private
    memoize
    def solution
      iteration.solution
    end
  end
end
