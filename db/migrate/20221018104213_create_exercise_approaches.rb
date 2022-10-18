class CreateExerciseApproaches < ActiveRecord::Migration[7.0]
  def change
    create_table :exercise_approaches do |t|
      t.belongs_to :exercise, foreign_key: true, null: false, type: :bigint

      t.string :uuid, null: false, index: true
      
      t.string :slug, null: false
      t.string :title, null: false
      t.string :blurb, null: false, limit: 350

      t.string :synced_to_git_sha, null: false

      t.timestamps

      t.index [:exercise_id, :uuid], unique: true
    end
  end
end
