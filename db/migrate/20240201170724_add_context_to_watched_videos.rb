class AddContextToWatchedVideos < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_watched_videos, :context, :string, null: true
    add_index :user_watched_videos, :context
  end
end
