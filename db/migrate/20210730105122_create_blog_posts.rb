class CreateBlogPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :blog_posts do |t|
      t.belongs_to :author, null: false, foreign_key: {to_table: :users}

      t.string :uuid, null: false
      t.string :slug, null: false
      t.string :category, null: false
      t.datetime :published_at, null: false

      t.string :title, null: false
      t.text :description
      t.string :marketing_copy, limit: 280
      t.string :image_url
      t.string :youtube_id

      t.timestamps

      t.index :uuid, unique: true
    end
  end
end
