class CreateExerciseContributorships < ActiveRecord::Migration[6.1]
  def change
    create_table :exercise_contributorships do |t|
      t.belongs_to :exercise, foreign_key: true
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
