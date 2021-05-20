class CreateGithubIssues < ActiveRecord::Migration[6.1]
  def change
    create_table :github_issues do |t|
      t.string :node_id, null: false, index: { unique: true }
      t.integer :number, null: false
      t.string :repo, null: false      
      t.string :title, null: false
      t.json :data, null: false
      # TODO: do we want to store the issue author too?

      t.timestamps
    end
  end
end
