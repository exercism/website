class CreateGithubPullRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :github_pull_requests do |t|
      t.integer :github_id, null: false, index: { unique: true }
      t.string :github_username, null: false
      t.json :github_event, null: false

      t.timestamps
    end
  end
end
