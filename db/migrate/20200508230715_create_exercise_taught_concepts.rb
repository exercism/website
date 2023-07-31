class CreateExerciseTaughtConcepts < ActiveRecord::Migration[7.0]
  def change
    create_table :exercise_taught_concepts do |t|
      t.belongs_to :exercise, foreign_key: true, null: false
      t.belongs_to :track_concept, foreign_key: true, null: false

      t.timestamps

      t.index %i[exercise_id track_concept_id], unique: true, name: 'uniq'
    end
  end
end
