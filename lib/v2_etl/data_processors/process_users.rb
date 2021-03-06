module V2ETL
  module DataProcessors
    class ProcessUsers
      include Mandate

      def call
        connection = ActiveRecord::Base.connection

        # Cache reputation
        connection.execute(<<-SQL)
        UPDATE users
        JOIN (
          SELECT user_id, SUM(user_reputation_tokens.value) as val
          FROM user_reputation_tokens
          GROUP BY user_reputation_tokens.user_id
        ) rt
        ON rt.user_id = users.id
        SET reputation = rt.val
        SQL
      end
    end
  end
end
