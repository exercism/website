class RemoveRequiresStudentActionSinceFromMentorDiscussions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production? 
    
    remove_column :mentor_discussions, :requires_student_action_since
  end
end
