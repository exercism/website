module V2ETL
  module DataProcessors
    class ProcessMentorRequests
      include Mandate

      def call
        connection = ActiveRecord::Base.connection
        connection.execute(<<-SQL)
        INSERT INTO mentor_requests (
          uuid,
          solution_id,
          track_id, exercise_id, student_id,
          status,
          comment_markdown, comment_html,
          created_at, updated_at
        )
        SELECT
          UUID(),
          solutions.id,
          exercises.track_id, solutions.exercise_id, solutions.user_id,
          0,
          "", "",
          solutions.mentoring_requested_at, solutions.mentoring_requested_at
        FROM solutions
        INNER JOIN exercises on exercises.id = solutions.exercise_id
        WHERE mentoring_requested_at IS NOT NULL
        AND approved_by_id IS NULL
        AND completed_AT IS NULL
        ORDER BY solutions.mentoring_requested_at ASC
        SQL

        # Delete requests where the person hasn't iterated (?!)
        Mentor::Request.where(
          solution_id: Solution.where("NOT EXISTS(SELECT TRUE FROM iterations WHERE iterations.solution_id = solutions.id)")
        ).delete_all

        # Mark as fullfiled any requests where there's a discussion
        Mentor::Request.where(
          solution_id: Mentor::Discussion.select(:solution_id)
        ).update_all(status: :fulfilled)

        Mentor::Discussion.joins("INNER JOIN mentor_requests ON mentor_discussions.solution_id = mentor_requests.solution_id").
          update_all("request_id = mentor_requests.id")

        Mentor::Discussion.connection.change_column_null :mentor_discussions, request_id, false
        Mentor::Discussion.connection.add_foreign_key :mentor_discussions, column: :request_id
      end
    end
  end
end
