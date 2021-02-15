class AddRenderingDataCacheToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :user_notifications, :rendering_data_cache, :json, null: false

    add_belongs_to :user_notifications, :track, null: true, foreign_key: true
    add_belongs_to :user_notifications, :exercise, null: true, foreign_key: true
  end
end
