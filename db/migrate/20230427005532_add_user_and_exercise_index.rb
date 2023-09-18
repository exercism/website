class AddUserAndExerciseIndex < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :solutions, [:user_id, :exercise_id]

    remove_index :solutions, name: "index_solutions_on_user_id"
  end
end
