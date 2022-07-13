class AddEmailOnStudentFinishedDiscussion < ActiveRecord::Migration[6.1]
  def change
    add_column :user_communication_preferences, :email_on_student_finished_discussion_notification, :boolean, default: true, null: false
  end
end
