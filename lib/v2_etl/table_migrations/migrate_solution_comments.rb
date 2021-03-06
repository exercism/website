require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateSolutionComments < TableMigration
      include Mandate

      def table_name
        "solution_comments"
      end

      def model
        Solution::Comment
      end

      def call
        add_non_nullable_column :uuid, :string, "UUID()"
      end
    end
  end
end

