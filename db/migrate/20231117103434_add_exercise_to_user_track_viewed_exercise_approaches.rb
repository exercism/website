class AddExerciseToUserTrackViewedExerciseApproaches < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_reference :user_track_viewed_exercise_approaches, :exercise, null: true, foreign_key: true, if_not_exists: true
    
    UserTrack::ViewedExerciseApproach.includes(:approach).find_each do |viewed_approach|
      viewed_approach.update_column(:exercise_id, viewed_approach.approach.exercise_id)
    end

    change_column_null :user_track_viewed_exercise_approaches, :exercise_id, false
  end
end
