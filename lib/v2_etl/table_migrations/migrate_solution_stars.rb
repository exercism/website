require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateSolutionStars < TableMigration
      include Mandate

      def table_name
        "solution_stars"
      end

      def model
        Solution::Star
      end

      def call
        # Nothing needs changing
      end
    end
  end
end

