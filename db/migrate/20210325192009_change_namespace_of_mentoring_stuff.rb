class ChangeNamespaceOfMentoringStuff < ActiveRecord::Migration[6.1]
  def change
    rename_table :solution_mentor_discussions, :mentor_discussions
    rename_table :solution_mentor_discussion_posts, :mentor_discussion_posts
    rename_table :solution_mentor_requests, :mentor_requests
  end
end
