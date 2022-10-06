class CreateExerciseApproachIntroductionContributorships < ActiveRecord::Migration[7.0]
  def change
    create_table :exercise_approach_introduction_contributorships do |t|
      t.belongs_to :exercise, foreign_key: true, null: false, index: { name: "index_exercise_approach_intro_contributorships_on_exercise_id" }
      t.belongs_to :user, foreign_key: true, null: false
  
      t.timestamps
  
      t.index %i[exercise_id user_id], unique: true, name: "index_exercise_approach_intro_contris_on_exercise_and_user"
    end
  end
end
