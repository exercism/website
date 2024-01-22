class AddPositionToExerciseApproaches < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :exercise_approaches, :position, :integer, null: true, limit: 1
    add_index :exercise_approaches, [:exercise_id, :position]

    # The positions will be fixed manually by running Git::SyncTrack.()
    Exercise::Approach.update_all(position: 0)

    change_column_null :exercise_approaches, :position, false
  end
end
