class AddDifficultyToExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :exercises, :difficulty, :tinyint, null: false, default: 1
  end
end
