require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateUserCommunicationPreferences < TableMigration
      include Mandate

      def table_name
        "user_communication_preferences"
      end

      def model
        User::CommunicationPreferences
      end

      def call
        # Do this last
        add_column :email_on_mentor_started_discussion_notification, :boolean, null: false, default: true

        remove_column :email_on_solution_approved
      end
    end
  end
end

