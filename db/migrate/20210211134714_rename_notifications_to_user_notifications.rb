class RenameNotificationsToUserNotifications < ActiveRecord::Migration[6.1]
  def change
    rename_table :notifications, :user_notifications
  end
end
