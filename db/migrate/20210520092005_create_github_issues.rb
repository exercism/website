class CreateGithubIssues < ActiveRecord::Migration[6.1]
  def change
    create_table :github_issues do |t|
      t.string :node_id, null: false, index: { unique: true }
      t.integer :number, null: false
      t.string :title, null: false
      t.column :status, :tinyint, null: false, default: 0
      t.string :repo, null: false      
      t.string :opened_by_username, null: false
      t.datetime :opened_at, null: false

      t.timestamps
    end

    create_table :github_issue_labels do |t|
      t.belongs_to :github_issue, null: false, foreign_key: true

      t.string :label, null: false

      t.index [:github_issue_id, :label], unique: true

      t.timestamps
    end
  end
end
