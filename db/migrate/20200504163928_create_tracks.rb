class CreateTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :tracks do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :title, null: false
      t.string :blurb, null: false, limit: 400

      t.string :repo_url, null: false

      t.string :synced_to_git_sha, null: false

      t.integer :num_exercises, limit: 3, null: false, default: 0
      t.integer :num_concepts, limit: 3, null: false, default: 0

      t.json :tags, null: true

      t.boolean :active, default: true, null: false

      t.integer :num_students, null: false, default: 0
      t.integer :median_wait_time

      t.timestamps
    end
  end
end
