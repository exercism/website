class CreateUserWatchedVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :user_watched_videos do |t|
      t.belongs_to :user, null: false
      t.integer :video_provider, null: false
      t.string :video_id, null: false

      t.timestamps
    end
  end
end
