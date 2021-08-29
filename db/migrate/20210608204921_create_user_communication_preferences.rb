class CreateUserCommunicationPreferences < ActiveRecord::Migration[6.1]
  def change
    create_table :user_communication_preferences do |t|
      t.belongs_to :user, null: false, foreign_key: true

      t.string :token, null: false, index: {unique: true}

      t.boolean :email_on_mentor_started_discussion_notification, default: true, null: false
      t.boolean :email_on_mentor_replied_to_discussion_notification, default: true, null: false
      t.boolean :email_on_student_replied_to_discussion_notification, default: true, null: false

      t.timestamps
    end
  end
end
