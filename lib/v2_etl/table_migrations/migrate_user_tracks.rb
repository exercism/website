require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateUserTracks < TableMigration
      include Mandate

      def table_name
        "user_tracks"
      end

      def model
        UserTrack
      end

      def call
        # We just delete "paused" user_tracks in v3
        UserTrack.where.not(paused_at: nil).destroy_all
        remove_column :paused_at

        # These were never used
        remove_column :handle

        add_column :summary_key, :string, null: true
        add_column :summary_data, :text, null: true

        add_non_nullable_column :last_touched_at, :datetime, 'updated_at'

        remove_column :independent_mode
        add_column :practice_mode, :boolean, null: false, default: false
        add_column :objectives, :text

        rename_column :anonymous, :anonymous_during_mentoring
      end
    end
  end
end
