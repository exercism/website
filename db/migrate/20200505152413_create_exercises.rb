class CreateExercises < ActiveRecord::Migration[6.0]
  def change
    create_table :exercises do |t|
      t.belongs_to :track, foreign_key: true, null: false

      t.string :uuid, null: false, index: true
      t.string :type, null: false

      t.string :slug, null: false
      t.string :title, null: false
      
      t.string :git_sha, null: false
      t.string :synced_to_git_sha, null: false

      t.boolean :deprecated, default: false, null: false

      t.timestamps

      t.index [:track_id, :uuid], unique: true
    end
  end
end
