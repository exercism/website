class CreatePullRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :git_pull_requests do |t|
      t.string :node_id, null: false, index: { unique: true }
      t.integer :number, null: false
      t.string :repo, null: false
      t.string :author_github_username, null: false
      t.json :data, null: false

      t.timestamps
    end

    create_table :git_pull_request_reviews do |t|
      t.belongs_to :git_pull_request, null: false, foreign_key: true

      t.string :node_id, null: false, index: { unique: true }
      t.string :reviewer_github_username, null: false

      t.timestamps
    end
  end
end
