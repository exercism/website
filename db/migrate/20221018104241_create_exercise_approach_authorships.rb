class CreateExerciseApproachAuthorships < ActiveRecord::Migration[7.0]
  def change
    create_table :exercise_approach_authorships do |t|
      t.belongs_to :exercise_approach, foreign_key: true, null: false, index: { name: "index_exercise_approaches_authorships_on_approach_id" }
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps

      t.index %i[exercise_approach_id user_id], unique: true, name: "index_exercise_approach_author_approach_id_user_id"
    end
  end
end
