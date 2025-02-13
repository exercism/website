class AddHasBonusTasksToBootcampExercises < ActiveRecord::Migration[7.0]
  def change
    add_column :bootcamp_exercises, :has_bonus_tasks, :boolean, default: false, null: false
  end
end
