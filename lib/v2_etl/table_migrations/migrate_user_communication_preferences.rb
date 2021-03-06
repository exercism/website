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
        rename_column :email_on_new_discussion_post_for_mentor, :email_on_student_replied_to_discussion_notification
        rename_column :email_on_new_iteration_for_mentor, :email_on_student_added_iteration_notification
        rename_column :email_on_new_discussion_post, :email_on_mentor_replied_to_discussion_notification

        rename_column :email_on_new_solution_comment_for_solution_user, :email_on_new_solution_comment_for_solution_user_notification
        rename_column :email_on_new_solution_comment_for_other_commenter, :email_on_new_solution_comment_for_other_commenter_notification

        remove_column :email_on_solution_approved
      end
    end
  end
end

