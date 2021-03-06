require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateSolutions < TableMigration
      include Mandate

      def table_name
        "solutions"
      end

      def model
        Solution
      end

      def call
        # Remove unnededed records before adding/deleting columns to speed things up.
        #
        # We're deliberately using delete_all here to ensure
        # there are no foreign keys that are upset
        Solution.where.not(id: Iteration.select(:solution_id)).
          where(downloaded_at: nil).
          delete_all

        add_column :num_views, :integer, limit: 3, null: false, default: 0
        add_column :num_loc, :integer, limit: 3, null: false, default: 0

        add_column :published_iteration_id, :bigint
        add_foreign_key :iterations, column: :published_iteration_id

        add_column :status, :tinyint, default: 0, null: false
        add_column :iteration_status, :string, null: true
        add_column :mentoring_status, :integer, limit: 1, default: 0, null: false

        add_column :snippet, :string, limit: 1500

        add_column :num_iterations, :tinyint, default: 0, null: false

        # Add missing columns
        add_non_nullable_column :type, :string, "'PracticeSolution'"
        add_non_nullable_column :public_uuid, :string, "UUID()"

        add_column :last_iterated_at, :datetime, null: true
        add_non_nullable_column :git_important_files_hash, :string, 'exercises.git_important_files_hash', joins: [:exercise]

        add_non_nullable_column :unique_key, :string, 'CONCAT(user_id, ":", exercise_id)'
        add_index :unique_key, unique: true
        remove_index name: :index_solutions_on_exercise_id_and_user_id

        # Remove redundant columns
        remove_column :last_updated_by_user_at
        remove_column :last_updated_by_mentor_at
        remove_column :num_mentors
        remove_column :mentoring_enabled
        remove_column :independent_mode
        remove_column :track_in_independent_mode
        remove_column :paused
        remove_column :is_legacy
        remove_column :reminder_sent_at
      end
    end
  end
end
