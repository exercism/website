class CreateExercises < ActiveRecord::Migration[7.0]
  def change
    create_table :exercises do |t|
      t.belongs_to :track, foreign_key: true, null: false, type: :bigint

      t.string :uuid, null: false, index: true
      t.string :type, null: false

      t.string :slug, null: false
      t.string :title, null: false
      t.string :blurb, null: false, limit: 350
      t.column :difficulty, :tinyint, null: false, default: 1
      t.column :status, :tinyint, null: false, default: 0

      t.string :git_sha, null: false
      t.string :synced_to_git_sha, null: false
      t.string :git_important_files_hash, null: false

      t.integer :position, null: false
      t.string :icon_name, null: false

      t.integer :median_wait_time

      t.timestamps

      t.index [:track_id, :uuid], unique: true
    end
  end
end
