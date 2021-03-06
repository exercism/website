require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateBlogPosts < TableMigration
      include Mandate

      def table_name
        "blog_posts"
      end

      def model
        BlogPost
      end

      def call
        add_column :description, :text
        add_column :youtube_id, :string

        add_non_nullable_column :author_id, :bigint do |post|
          post.update(author: User.find_by(handle: post.author_handle) || User.first)
        end
        add_foreign_key :users, column: :author_id

        remove_column :author_handle
        remove_column :content_repository
        remove_column :content_filepath

      end
    end
  end
end


