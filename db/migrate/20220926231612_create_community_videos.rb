class CreateCommunityVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :community_videos do |t|
      t.belongs_to :track, foreign_key: true, null: true
      t.belongs_to :exercise, foreign_key: true, null: true
      t.belongs_to :author, foreign_key: { to_table: "users" }, null: true

      t.belongs_to :submitted_by, foreign_key: { to_table: "users" }, null: false

      t.integer :status, size: 1, null: false, default: 0
      t.integer :platform, size: 1, null: false

      t.string :title, null: false
      t.string :url, null: false
      t.string :watch_id, null: false
      t.string :embed_id, null: false

      t.string :channel_name, null: false
      t.string :thumbnail_url, null: false

      t.timestamps
    end
  end
end
