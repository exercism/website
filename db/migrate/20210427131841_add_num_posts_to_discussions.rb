class AddNumPostsToDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_discussions, :num_posts, :integer, limit:3, null: false, default: 0
  end
end
