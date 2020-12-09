class CreateExerciseContributorships < ActiveRecord::Migration[6.1]
  def change
    create_table :exercise_contributorships do |t|
      t.belongs_to :exercise, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
