class AddStatusToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :user_notifications, :status, :tinyint, null: false, default: 0
  end
end
