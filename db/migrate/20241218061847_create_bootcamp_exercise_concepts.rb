class CreateBootcampExerciseConcepts < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_exercise_concepts do |t|
      t.references :exercise, null: false, foreign_key:  {to_table: :bootcamp_exercises}
      t.references :concept, null: false, foreign_key: {to_table: :bootcamp_concepts}

      t.timestamps

      t.index [:exercise_id, :concept_id], unique: true
    end
  end
end
