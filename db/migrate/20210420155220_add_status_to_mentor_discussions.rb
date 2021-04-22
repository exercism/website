class AddStatusToMentorDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_discussions, :status, :tinyint, null: false, default: 0
    add_column :mentor_discussions, :mentor_finished_at, :datetime, null: true
    rename_column :mentor_discussions, :finished_at, :student_finished_at
  end
end
