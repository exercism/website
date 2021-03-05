class CreatePullRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :pull_requests do |t|
      t.string :node_id, null: false, index: { unique: true }
      t.string :repo, null: false
      t.integer :number, null: false
      t.string :author, null: false
      t.json :event, null: false

      t.timestamps
    end
  end
end
