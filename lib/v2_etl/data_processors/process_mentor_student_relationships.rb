module V2ETL
  module DataProcessors
    class ProcessMentorStudentRelationships
      include Mandate

      def call
        ActiveRecord::Base.connection.execute(<<-SQL)
        INSERT INTO mentor_student_relationships (
          mentor_id,
          student_id,
          num_discussions,
          created_at, updated_at
        )
        SELECT
          mentor_id, solutions.user_id, COUNT(*),
          #{V2ETL::RUN_TIME}, #{V2ETL::RUN_TIME}
        FROM mentor_discussions
        INNER JOIN solutions on solutions.id = mentor_discussions.solution_id
        GROUP BY mentor_id, solutions.user_id
        SQL
      end
    end
  end
end
