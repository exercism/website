class AddRenderingDataCacheToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :user_notifications, :rendering_data_cache, :json, null: false
  end
end
