require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateIterations < TableMigration
      include Mandate

      def table_name
        "iterations"
      end

      def model
        Iteration
      end

      def call
        # Create a submission for each iteration
        puts "Migrating iterations -> submissions"
        ActiveRecord::Base.connection.execute(<<-SQL)
        INSERT INTO submissions (
          id, uuid, solution_id,
          tests_status, representation_status, analysis_status, submitted_via,
          git_slug, git_sha, created_at, updated_at
        )
        SELECT
          iterations.id, UUID(), iterations.solution_id,
          0, 0, 0, 'cli',
          '', '', NOW(), NOW()
        FROM iterations
        SQL

        # Add a couple of straight-forward columns
        add_non_nullable_column :submission_id, :bigint, "id"
        add_non_nullable_column :uuid, :string, "UUID()"

        # Set correct idx for all solutions
        add_non_nullable_column :idx, :integer, "1", limit: 1

        # https://stackoverflow.com/questions/45494/mysql-error-1093-cant-specify-target-table-for-update-in-from-clause
        puts "Set correct iteration idx"
        ActiveRecord::Base.connection.execute("SET optimizer_switch = 'derived_merge=off'")
        Iteration.in_batches do |relation|
          relation.update_all("idx = (
            SELECT * FROM (
              SELECT COUNT(*) + 1
              FROM iterations inner_its
              WHERE inner_its.solution_id = iterations.solution_id
              AND inner_its.id < iterations.id
            ) as x)
          ")
        end
        ActiveRecord::Base.connection.execute("SET optimizer_switch = 'derived_merge=on'")

        # TODO: Set to true if it's the final iteration
        add_column :published, :boolean, default: false

        add_column :snippet, :string, limit: 1500

        # Add indexes
        add_index :submission_id, unique: true
      end
    end
  end
end
