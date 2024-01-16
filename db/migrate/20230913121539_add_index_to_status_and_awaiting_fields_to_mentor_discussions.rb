class AddIndexToStatusAndAwaitingFieldsToMentorDiscussions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :mentor_discussions, [:status, :awaiting_student_since]
    add_index :mentor_discussions, [:status, :awaiting_mentor_since]
  end
end
