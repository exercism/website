class AddAnonymousModeToMentorDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_discussions, :anonymous_mode, :boolean, default: false, null: false
  end
end
