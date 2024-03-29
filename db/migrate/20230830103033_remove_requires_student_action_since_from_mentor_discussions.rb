class RemoveRequiresStudentActionSinceFromMentorDiscussions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production? 
    if column_exists?(:mentor_discussions, :requires_student_action_since)
      remove_column :mentor_discussions, :requires_student_action_since
    end  
    end
end
