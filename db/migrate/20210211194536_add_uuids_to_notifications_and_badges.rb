class AddUuidsToNotificationsAndBadges < ActiveRecord::Migration[6.1]
  def change
    add_column :user_notifications, :uuid, :string, null: true
    User::Notification.find_each {|n|n.update(uuid: SecureRandom.uuid) }
    change_column_null :user_notifications, :uuid, false
    add_index :user_notifications, :uuid, unique: true

    add_column :user_acquired_badges, :uuid, :string, null: false
    User::AcquiredBadge.find_each {|n|n.update(uuid: SecureRandom.uuid) }
    change_column_null :user_acquired_badges, :uuid, false
    add_index :user_acquired_badges, :uuid, unique: true
  end
end
