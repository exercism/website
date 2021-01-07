class AddReadFlagsToMentorDiscussionPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :solution_mentor_discussion_posts, :seen_by_student, :boolean, null: false, default: false
    add_column :solution_mentor_discussion_posts, :seen_by_mentor, :boolean, null: false, default: false
  end
end
