class AddBecomeMentorAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :became_mentor_at, :datetime, null: true
  end
end
