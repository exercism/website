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
        add_column :reputation, :integer, default: 0, null: false
        add_column :stripe_customer_id, :string, null: true
        add_column :total_donated_in_cents, :integer, null: true, default: 0
        add_column :active_donation_subscription, :boolean, null: true, default: false

        add_column :roles, :json, null: true

        # Add indexes
        add_index %w[provider uid], unique: true
        add_index :stripe_customer_id, unique: true
        add_index :github_username, unique: true

        add_column :num_solutions_mentored, :integer, limit: 3, null: false, default: 0
        add_column :mentor_satisfaction_percentage, :integer, limit: 1, null: true

        add_column :became_mentor_at, :datetime
        User.where(is_mentor: true).update_all(became_mentor_at: V2ETL::RUN_TIME)
        remove_column :is_mentor

        remove_column :show_v3_patience_modal
        remove_column :show_introducing_research_modal
      end
    end
  end
end
