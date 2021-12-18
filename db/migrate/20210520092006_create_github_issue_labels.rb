class CreateGithubIssueLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :github_issue_labels do |t|
      t.belongs_to :github_issue, null: false, foreign_key: true

      t.string :name, null: false

      t.index [:github_issue_id, :name], unique: true

      t.timestamps
    end
  end
end

