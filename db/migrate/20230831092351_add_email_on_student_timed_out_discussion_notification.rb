class AddEmailOnStudentTimedOutDiscussionNotification < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_communication_preferences, :email_on_student_timed_out_discussion_notification, :boolean, default: true, null: false
  end
end
