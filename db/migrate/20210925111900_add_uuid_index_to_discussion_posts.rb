class AddUuidIndexToDiscussionPosts < ActiveRecord::Migration[7.0]
  def change
    add_index :mentor_discussion_posts, :uuid, unique: true
  end
end
