class AddPathToNotifications < ActiveRecord::Migration[6.1]
  def change
    User::Notification.delete_all
    add_column :user_notifications, :path, :string, null: false
  end
end
