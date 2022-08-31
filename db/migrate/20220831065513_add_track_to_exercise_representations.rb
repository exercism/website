class AddTrackToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_reference :exercise_representations, :track, null: true, foreign_key: true, if_not_exists: true

    unless Rails.env.production?
      exercise_track_id_sql = Arel.sql(Exercise.where(id: :exercise_id).select(:track_id).to_sql)
      Exercise::Representation.update_all("track_id = (#{exercise_track_id_sql})")
    end
  end
end
