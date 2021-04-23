class AddRatingToMentorDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_discussions, :rating, :tinyint, null: true
  end
end
