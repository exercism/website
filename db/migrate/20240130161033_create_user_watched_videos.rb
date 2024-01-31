class CreateUserWatchedVideos < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :user_watched_videos do |t|
      t.belongs_to :user, null: false
      t.integer :video_provider, null: false
      t.string :video_id, null: false

      t.timestamps

      t.index [:user_id, :video_provider, :video_id], unique: true, name: "user_watched_videos_uniq"
    end
  end
end
