class AddEmailOnDonationNotificationToCommunicationPreferences < ActiveRecord::Migration[7.0]
  def change
    add_column :user_communication_preferences, :email_on_donation_notification, :boolean, default: true, null: false
  end
end
