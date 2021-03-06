module V2ETL
  module DataProcessors
    class ProcessMentoringReputation
      include Mandate

      def call
        connection = ActiveRecord::Base.connection
        connection.execute(<<-SQL)
        INSERT INTO user_reputation_tokens (
          uuid, type,
          user_id, exercise_id, track_id,
          params,
          uniqueness_key,
          version, rendering_data_cache, value, reason, category,
          created_at, updated_at, earned_on
        )
        SELECT
        UUID(), "User::ReputationTokens::MentoredToken",
        mentor_id, exercise_id, track_id,
        CONCAT('{"discussion": "gid://website/Mentor::Discussion/', mentor_discussions.id, '"}'),
        CONCAT(mentor_id, "|mentored|Discussion#", mentor_discussions.id),
        1, "{}", 5, "mentored", "mentoring",
        #{V2ETL::RUN_TIME}, #{V2ETL::RUN_TIME}, mentor_discussions.created_at
        FROM mentor_discussions
        INNER JOIN solutions on solutions.id = mentor_discussions.solution_id
        INNER JOIN exercises on solutions.exercise_id = exercises.id
        WHERE mentor_discussions.status = 4 AND (
          rating IS NULL 
          OR rating = 3
          OR rating = 4
          OR rating = 5
        )
        SQL
      end
    end
  end
end


