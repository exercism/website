class AddCommunicationPreferenceForNudges < ActiveRecord::Migration[6.1]
  def change
    add_column :user_communication_preferences, :email_on_usage_nudge_notification, :boolean, null: false, default: true
  end
end
