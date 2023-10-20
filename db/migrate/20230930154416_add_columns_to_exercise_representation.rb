class AddColumnsToExerciseRepresentation < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :exercise_representations, :oldest_solution_id, :bigint, null: true
    add_column :exercise_representations, :prestigious_solution_id, :bigint, null: true
  end
end
