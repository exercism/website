class Iteration
  class Destroy
    include Mandate

    initialize_with :iteration

    def call
      iteration.update!(deleted_at: Time.current)

      # Unpublish the solution if this was the published iteration
      solution.update!(published_iteration_id: nil, published_at: nil) if solution.published_iteration_id == iteration.id

      # Uncomplete the solution if there are now no iterations
      solution.update!(completed_at: nil) unless solution.iterations.not_deleted.exists?
    end

    private
    def solution
      iteration.solution
    end
  end
end
