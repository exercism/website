class Iteration
  class Destroy
    include Mandate

    initialize_with :iteration

    def call
      iteration.update!(deleted_at: Time.current)
      solution.update!(published_iteration_id: nil, published_at: nil) if solution.published_iteration_id == iteration.id
      solution.update!(completed_at: nil) if solution.iterations.not_deleted.empty?
    end

    private
    def solution
      iteration.solution
    end
  end
end
