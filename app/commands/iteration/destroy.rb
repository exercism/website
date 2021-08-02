class Iteration
  class Destroy
    include Mandate

    initialize_with :iteration

    def call
      iteration.update!(deleted_at: Time.current)
      solution.update!(published_iteration_id: nil) if solution.published_iteration_id == iteration.id
    end

    private
    def solution
      iteration.solution
    end
  end
end
