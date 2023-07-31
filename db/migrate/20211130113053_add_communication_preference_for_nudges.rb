class AddCommunicationPreferenceForNudges < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER TABLE `user_communication_preferences` ADD `email_on_nudge_notification` tinyint(1) DEFAULT TRUE NOT NULL, ALGORITHM=INPLACE, LOCK=NONE"
  end

  def down
    remove_column :user_communication_preferences, :email_on_nudge_notification
  end
end
