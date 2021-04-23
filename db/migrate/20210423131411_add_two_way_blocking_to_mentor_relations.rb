class AddTwoWayBlockingToMentorRelations < ActiveRecord::Migration[6.1]
  def change
    rename_column :mentor_student_relationships, :blocked, :blocked_by_mentor
    add_column :mentor_student_relationships, :blocked_by_student, :boolean, null: false, default: false
  end
end
