class AddRequiresAction < ActiveRecord::Migration[6.1]
  def change
    add_column :solution_mentor_discussions, :requires_mentor_action_since, :datetime, null: true
    add_column :solution_mentor_discussions, :requires_student_action_since, :datetime, null: true
  end
end
