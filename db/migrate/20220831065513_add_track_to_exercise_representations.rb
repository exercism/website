class AddTrackToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_reference :exercise_representations, :track, null: true, foreign_key: true, if_not_exists: true

    unless Rails.env.production?
      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        Exercise::Representation.includes(:exercise).find_each do |representation|
          Exercise::Representation
            .where(id: representation.id)
            .update_all(track_id: representation.exercise.track_id)
        end
      end
    end
  end
end
