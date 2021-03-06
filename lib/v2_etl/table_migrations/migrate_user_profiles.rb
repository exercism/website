require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateUserProfiles < TableMigration
      include Mandate

      def table_name
        "user_profiles"
      end

      def model
        UserProfile
      end

      def call
        # TODO: What do we want to do with this field?
        # Should this be in profile or part of a user?
        change_column_null :display_name, true

        User::Profile.where(id: [
          4005, 4006, 42135, 52983, 57704
        ]).delete_all

        add_index :user_id, unique: true
      end
    end
  end
end
