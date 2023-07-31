class CreateExerciseAuthorships < ActiveRecord::Migration[7.0]
  def change
    create_table :exercise_authorships do |t|
      t.belongs_to :exercise, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps

      t.index %i[exercise_id user_id], unique: true
    end
  end
end
