require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateUsers < TableMigration
      include Mandate

      def table_name
        "users"
      end

      def call
        # Remove tracking columns
        remove_column :current_sign_in_at
        remove_column :last_sign_in_at
        remove_column :sign_in_count
        remove_column :current_sign_in_ip
        remove_column :last_sign_in_ip

        # Remove redundant columns
        remove_column :full_width_code_panes
        remove_column :may_edit_changelog

        # Add missing columns
        add_column :github_username, :string
        add_column :location, :string
        add_column :pronouns, :string
        add_column :became_mentor_at, :datetime
        add_column :reputation, :integer, default: 0, null: false

        add_column :roles, :json, null: true

        # Add indexes
        add_index %w[provider uid], unique: true
        add_index :github_username, unique: true

        # TODO: Move default_allow_comments to preferences
        # TODO: Migrate show_v3_patience_modal
        # TODO: Migrate show_introducing_research_modal
      end
    end
  end
end
