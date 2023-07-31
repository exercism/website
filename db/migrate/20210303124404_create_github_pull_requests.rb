class CreateGithubPullRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :github_pull_requests do |t|
      t.string :node_id, null: false, index: { unique: true }
      t.integer :number, null: false
      t.string :repo, null: false
      t.string :author_username, null: true
      t.string :merged_by_username, null: true
      t.string :title, null: true
      t.text :data, null: false

      t.timestamps
    end

    create_table :github_pull_request_reviews do |t|
      t.belongs_to :github_pull_request, null: false, foreign_key: true

      t.string :node_id, null: false, index: { unique: true }
      t.string :reviewer_username, null: true

      t.timestamps
    end
  end
end
