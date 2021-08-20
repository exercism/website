class AddCommunicationPreferences < ActiveRecord::Migration[6.1]
  def change
    add_column :user_communication_preferences, :email_on_mentor_replied_to_discussion_notification, :boolean, default: true, null: false
    add_column :user_communication_preferences, :email_on_student_replied_to_discussion_notification, :boolean, default: true, null: false
  end
end
