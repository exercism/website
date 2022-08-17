class AddLastShownAtToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_representations, :last_shown_at, :datetime, null: true, if_not_exists: true
  end
end
