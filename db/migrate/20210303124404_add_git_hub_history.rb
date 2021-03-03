class AddGitHubHistory < ActiveRecord::Migration[6.1]
  def change
    create_table :github_pull_requests do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.string :github_username, null: false
      t.json :github_event, null: false

      t.timestamps
    end

    create_table :github_pull_request_reviews do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.string :github_username, null: false
      t.json :github_event, null: false

      t.timestamps
    end
  end
end
