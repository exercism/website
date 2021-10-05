class AddUuidIndexToDiscussionPosts < ActiveRecord::Migration[6.1]
  def change
    add_index :mentor_discussion_posts, :uuid, unique: true
  end
end
