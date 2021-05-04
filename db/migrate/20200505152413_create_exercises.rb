class CreateExercises < ActiveRecord::Migration[6.0]
  def change
    create_table :exercises do |t|
      t.belongs_to :track, foreign_key: true, null: false

      t.string :uuid, null: false, index: true
      t.string :type, null: false

      t.string :slug, null: false
      t.string :title, null: false
      # TODO: Make null: false before launch (Check ETL won't break)
      t.string :blurb, null: true, limit: 350
      t.column :difficulty, :tinyint, null: false, default: 1
      t.column :status, :tinyint, null: false, default: 0

      t.string :git_sha, null: false
      t.string :synced_to_git_sha, null: false

      t.integer :position, null: false

      t.timestamps

      t.index [:track_id, :uuid], unique: true
    end
  end
end
