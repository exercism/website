class CreateTrackConcepts < ActiveRecord::Migration[7.0]
  def change
    create_table :track_concepts do |t|
      t.belongs_to :track, foreign_key: true, null: false

      t.string :slug, null: false
      t.string :uuid, null: false, index: { unique: true }

      t.string :name, null: false
      t.string :blurb, null: false, limit: 350
      t.string :synced_to_git_sha, null: false

      t.timestamps
    end
  end
end
