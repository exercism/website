module V2ETL
  module DataProcessors
    class ProcessPublishingReputation
      include Mandate

      def call
        connection = ActiveRecord::Base.connection

        [
          ["easy", 1, [1,2,3]],
          ["medium", 2, [4,5,6]],
          ["hard", 3, [7,8,9,10]]
        ].each do |level, value, difficulties|
          difficulties.each do |difficulty|
            connection.execute(<<-SQL)
            INSERT INTO user_reputation_tokens (
              uuid, type,
              user_id, exercise_id, track_id,
              params,
              uniqueness_key,
              version, rendering_data_cache, value, reason, category,
              level,
              created_at, updated_at, earned_on
            )
            SELECT
            UUID(), "User::ReputationTokens::PublishedSolutionToken",
            user_id, solutions.exercise_id, exercises.track_id,
            CONCAT('{"solution": "gid://website/PracticeSolution/', solutions.id, '"}'),
            CONCAT(user_id, "|published_solution|Solution#", solutions.id),
            1, "{}", #{value}, "published_solution", "publishing",
            "#{level}",
            #{V2ETL::RUN_TIME}, #{V2ETL::RUN_TIME}, solutions.published_at
            FROM solutions 
            INNER JOIN exercises on solutions.exercise_id = exercises.id
            WHERE published_at IS NOT NULL
            AND exercises.difficulty = #{difficulty}
            SQL
          end
        end
      end
    end
  end
end
