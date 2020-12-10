class AddUsersGithubUsername < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :github_username, :string, null: true
  end
end
