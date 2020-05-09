class CreateExercisePrerequisites < ActiveRecord::Migration[6.0]
  def change
    create_table :exercise_prerequisites do |t|
      t.belongs_to :exercise, null: false
      t.belongs_to :track_concept, null: false

      t.timestamps

      t.index [:exercise_id, :track_concept_id], unique: true
    end
  end
end
