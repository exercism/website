class RenameMentorDiscussionFields < ActiveRecord::Migration[6.1]
  def change
    rename_column :mentor_discussions, :requires_student_action_since, :awaiting_student_since
    rename_column :mentor_discussions, :requires_mentor_action_since, :awaiting_mentor_since
  end
end
