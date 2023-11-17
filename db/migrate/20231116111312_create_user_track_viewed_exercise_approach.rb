class CreateUserTrackViewedExerciseApproach < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :user_track_viewed_exercise_approaches do |t|
      t.references :user, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.references :approach, null: false, foreign_key: { to_table: :exercise_approaches }, index: { name: "index_user_track_viewed_exercise_approaches_on_approach_id" }

      t.index %i[user_id track_id approach_id], unique: true, name: "index_user_track_viewed_exercise_approaches_uniq"

      t.timestamps
    end
  end
end
