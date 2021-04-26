class AddFinishedByToMentorDiscussions < ActiveRecord::Migration[6.1]
  def change
    rename_column :mentor_discussions, :student_finished_at, :finished_at
    remove_column :mentor_discussions, :mentor_finished_at
    add_column :mentor_discussions, :finished_by, :tinyint, null: true
  end
end
