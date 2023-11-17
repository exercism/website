class AddExerciseToUserTrackViewedCommunitySolutions < ActiveRecord::Migration[7.0]
  def change    
    return if Rails.env.production?

    add_reference :user_track_viewed_community_solutions, :exercise, null: true, foreign_key: true, if_not_exists: true
    
    UserTrack::ViewedCommunitySolution.includes(:solution).find_each do |viewed_solution|
      viewed_solution.update_column(:exercise_id, viewed_solution.solution.exercise_id)
    end

    change_column_null :user_track_viewed_community_solutions, :exercise_id, false
  end
end
