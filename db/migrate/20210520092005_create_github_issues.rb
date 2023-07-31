class CreateGithubIssues < ActiveRecord::Migration[7.0]
  def change
    create_table :github_issues do |t|
      t.string :node_id, null: false, index: { unique: true }
      t.integer :number, null: false
      t.string :title, null: false
      t.column :status, :tinyint, null: false, default: 0
      t.string :repo, null: false      
      t.string :opened_by_username, null: true
      t.datetime :opened_at, null: false

      t.timestamps
    end
  end
end
