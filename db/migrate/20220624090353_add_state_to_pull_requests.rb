class AddStateToPullRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :github_pull_requests, :state, :tinyint, default: 1, null: false, if_not_exists: true
  end
end
