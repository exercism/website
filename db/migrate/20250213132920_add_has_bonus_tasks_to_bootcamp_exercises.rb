class AddHasBonusTasksToBootcampExercises < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    add_column :bootcamp_exercises, :has_bonus_tasks, :boolean, default: false, null: false
  end
end
