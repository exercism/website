class ImproveIndexForMentorDiscussions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :mentor_discussions, [:mentor_id, :status]
    remove_index :mentor_discussions, [:mentor_id]

    add_index :mentor_testimonials, [:mentor_id, :revealed]
    remove_index :mentor_testimonials, [:mentor_id]
  end
end
