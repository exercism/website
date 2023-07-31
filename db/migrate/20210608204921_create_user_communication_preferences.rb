class CreateUserCommunicationPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :user_communication_preferences do |t|
      t.belongs_to :user, null: false, foreign_key: true

      t.string :token, null: true, index: {unique: true}

      t.boolean :email_on_mentor_started_discussion_notification, default: true, null: false
      t.boolean :email_on_mentor_replied_to_discussion_notification, default: true, null: false
      t.boolean :email_on_student_replied_to_discussion_notification, default: true, null: false
      t.boolean :email_on_student_added_iteration_notification, default: true, null: false

      t.boolean :email_on_new_solution_comment_for_solution_user_notification, default: true, null: false
      t.boolean :email_on_new_solution_comment_for_other_commenter_notification, default: true, null: false
      t.boolean :receive_product_updates, default: true, null: false
      t.boolean :email_on_remind_mentor, default: true, null: false
      t.boolean :email_on_mentor_heartbeat, default: true, null: false

      t.timestamps
    end
  end
end
