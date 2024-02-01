class AddContextToWatchedVideos < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_watched_videos, :context, :integer, null: false, default: 0
  end
end
