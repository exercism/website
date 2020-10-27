class Iteration
  class Create
    include Mandate

    initialize_with :solution, :submission

    def call
      id = Iteration.connection.insert(%{
        INSERT INTO iterations (solution_id, submission_id, idx, created_at, updated_at)
        SELECT #{solution.id}, #{submission.id}, (COUNT(*) + 1), NOW(), NOW()
        FROM iterations where solution_id = #{solution.id}
      })
      Iteration.find(id)
    rescue ActiveRecord::RecordNotUnique
      Iteration.find_by!(solution: solution, submission: submission)
    end
  end
end
