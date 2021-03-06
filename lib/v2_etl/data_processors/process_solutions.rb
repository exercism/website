module V2ETL
  module DataProcessors
    class ProcessSolutions
      include Mandate

      def call
        Solution.where(status: 0).where.not(published_at: nil).update_all(status: :published)
        Solution.where(status: 0).where.not(completed_at: nil).update_all(status: :completed)
        Solution.where(status: 0).where(id: Iteration.select(:solution_id)).update_all(status: :iterated)

        Solution.where(mentoring_status: 0).where(id: Mentor::Discussion.where.not(status: %i[mentor_finished finished]).select(:solution_id)).update_all(mentoring_status: :in_progress)
        Solution.where(mentoring_status: 0).where(id: Mentor::Discussion.where(status: %i[mentor_finished finished]).select(:solution_id)).update_all(mentoring_status: :finished)
        Solution.where(mentoring_status: 0).where(id: Mentor::Request.select(:solution_id)).update_all(mentoring_status: :requested)

        ActiveRecord::Base.connection.execute("
        UPDATE solutions SET num_iterations = (
          SELECT COUNT(*) from iterations
          WHERE iterations.solution_id = solutions.id
        )")

        # Update all solutions to latest git shas
        # The important_files_has is already set by this point
        Solution.joins(:exercise).update_all(
          "solutions.git_slug = exercises.slug,
           solutions.git_sha = exercises.git_sha
           solutions.git_important_files_hash = exercises.git_important_files_hash"
        )

        # Set last iteration to be published if the solution is published.
        ActiveRecord::Base.connection.execute(<<-SQL)
          UPDATE solutions
          JOIN
          (
              SELECT MAX(id) as id, solution_id
              FROM iterations
              GROUP BY solution_id
              ORDER BY id ASC
          ) its
          ON its.solution_id = solutions.id
          SET solutions.published_iteration_id = its.id
          WHERE solutions.published_at IS NOT NULL
        SQL
      end
    end
  end
end
