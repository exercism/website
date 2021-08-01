module V2ETL
  module DataProcessors
    class ProcessActivities
      include Mandate

      def call
        puts "Adding submitted iteration activities"
        ActiveRecord::Base.connection.execute(<<-SQL)
        INSERT INTO user_activities (
          type,
          user_id, track_id, exercise_id, solution_id,
          params,
          uniqueness_key,
          version, rendering_data_cache,
          occurred_at, created_at, updated_at
        )
        SELECT
          "User::Activities::SubmittedIterationActivity",
          user_id, track_id, exercise_id, solution_id,
          CONCAT('{"iteration": "gid://website/Iteration/', iterations.id, '"}'),
          CONCAT(user_id, "|submitted_iteration|Iteration#", iterations.id),
          1, "{}",
          iterations.created_at, iterations.created_at, iterations.created_at
        FROM iterations
        INNER JOIN solutions on solutions.id = iterations.solution_id
        INNER JOIN exercises on exercises.id = solutions.exercise_id
        SQL

        puts "Adding started exercise activities"
        ActiveRecord::Base.connection.execute(<<-SQL)
        INSERT INTO user_activities (
          type,
          user_id, track_id, exercise_id, solution_id,
          params,
          uniqueness_key,
          version, rendering_data_cache,
          occurred_at, created_at, updated_at
        )
        SELECT
          "User::Activities::StartedExerciseActivity",
          user_id, track_id, exercise_id, solutions.id,
          "{}",
          CONCAT(user_id, "|started_exercise|Solution#", solutions.id),
          1, "{}",
          solutions.downloaded_at, solutions.downloaded_at, solutions.downloaded_at
        FROM solutions
        INNER JOIN exercises on exercises.id = solutions.exercise_id
        WHERE solutions.downloaded_at IS NOT NULL
        SQL

        puts "Adding completed exercise activities"
        ActiveRecord::Base.connection.execute(<<-SQL)
        INSERT INTO user_activities (
          type,
          user_id, track_id, exercise_id, solution_id,
          params,
          uniqueness_key,
          version, rendering_data_cache,
          occurred_at, created_at, updated_at
        )
        SELECT
          "User::Activities::CompletedExerciseActivity",
          user_id, track_id, exercise_id, solutions.id,
          "{}",
          CONCAT(user_id, "|completed_exercise|Solution#", solutions.id),
          1, "{}",
          solutions.completed_at, solutions.completed_at, solutions.completed_at
        FROM solutions
        INNER JOIN exercises on exercises.id = solutions.exercise_id
        WHERE solutions.completed_at IS NOT NULL
        SQL
      end
    end
  end
end

