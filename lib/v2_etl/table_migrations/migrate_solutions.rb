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
        # TODO: Do we still want this?
        # num_reactions

        # TODO: Add to v3
        # reflection
        # show_on_profile
        # allow_comments
        # num_comments
        # num_stars

        # TODO: Move this to solution_mentorship?
        # reminder_sent_at

        # Remove unnededed records before adding/deleting columns to speed things up.
        #
        # We're deliberately using delete_all here to ensure
        # there are no foreign keys that are upset
        Solution.where.not(id: Iteration.select(:solution_id)).
          where(downloaded_at: nil).
          delete_all

        add_column :status, :tinyint, default: 0, null: false
        add_column :iteration_status, :string, null: true
        add_column :mentoring_status, :integer, limit: 1, default: 0, null: false

        add_column :snippet, :string, limit: 1500

        add_column :num_iterations, :tinyint, default: 0, null: false

        # Add missing columns
        add_non_nullable_column :type, :string, "'PracticeSolution'"

        # Remove redundant columns
        remove_column :last_updated_by_user_at
        remove_column :last_updated_by_mentor_at
        remove_column :num_mentors
        remove_column :mentoring_enabled
        remove_column :independent_mode
        remove_column :track_in_independent_mode
        remove_column :paused
        remove_column :is_legacy
      end
    end
  end
end
