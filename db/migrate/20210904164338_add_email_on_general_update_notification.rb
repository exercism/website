class AddEmailOnGeneralUpdateNotification < ActiveRecord::Migration[7.0]
  def change
    add_column :user_communication_preferences, :email_on_general_update_notification, :boolean, default: true, null: false
  end
end
