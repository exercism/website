class AddTypeToBootcampExercises < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :bootcamp_exercises, :blocks_project_progression, :boolean, default: true, null: false
    add_column :bootcamp_exercises, :blocks_level_progression, :boolean, default: true, null: false
  end
end
