class CreateBlogPosts < ActiveRecord::Migration[6.1]
  def change
    create_table :blog_posts do |t|
      t.belongs_to :author, null: false, foreign_key: {to_table: :users}

      t.string :git_filepath, null: false

      t.string :uuid, null: false
      t.string :slug, null: false
      t.string :category, null: false
      t.datetime :published_at, null: false

      t.string :title, null: false
      t.string :marketing_copy, limit: 280
      t.string :image_url
      t.string :youtube_url

      t.timestamps
    end
  end
end
