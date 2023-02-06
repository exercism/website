class AddEmailOnAutomatedFeedbackAddedNotificationToUserCommunicationPreferences < ActiveRecord::Migration[7.0]
  def change
    add_column :user_communication_preferences, :email_on_automated_feedback_added_notification, :boolean, default: true, null: false
  end
end
