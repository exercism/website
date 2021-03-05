class CreatePullRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :git_pull_requests do |t|
      t.string :node_id, null: false, index: { unique: true }
      t.integer :number, null: false
      t.string :repo, null: false
      t.string :author, null: false
      t.json :event, null: false

      t.timestamps
    end
  end
end
