class AddNumExercisesCache < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :num_exercises, :integer, limit: 3, null: false, default: 0
    add_column :tracks, :num_concepts, :integer, limit: 3, null: false, default: 0
  end
end
