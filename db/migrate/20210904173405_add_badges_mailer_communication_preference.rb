class AddBadgesMailerCommunicationPreference < ActiveRecord::Migration[6.1]
  def change
    add_column :user_communication_preferences, :email_on_acquired_badge_notification, :boolean, default: true, null: false
  end
end
