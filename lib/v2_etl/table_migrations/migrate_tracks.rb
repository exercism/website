require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateTracks < TableMigration
      include Mandate

      def table_name
        "tracks"
      end

      def model
        Track
      end

      def call
        remove_column :syntax_highligher_language
        remove_column :syntax_highlighter_language

        remove_column :bordered_green_icon_url
        remove_column :bordered_turquoise_icon_url
        remove_column :hex_green_icon_url
        remove_column :hex_turquoise_icon_url
        remove_column :hex_white_icon_url

        # We read these from the git instead
        remove_column :code_sample
        remove_column :introduction

        # These should all get set by the syncer
        add_non_nullable_column :blurb, :string, "''", limit: 400
        add_non_nullable_column :synced_to_git_sha, :string, "''"
        add_column :tags, :json
        add_column :num_exercises, :integer, limit: 3, default: 0, null: false
        add_column :num_concepts, :integer, limit: 3, default: 0, null: false

        add_index :slug, unique: true
      end
    end
  end
end
