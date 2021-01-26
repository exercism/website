class RemoveActionColumnFromExerciseRepresentations < ActiveRecord::Migration[6.1]
  def change
    remove_column :exercise_representations, :action
  end
end
