class AddSolutionStarsIndex < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :solutions, [:exercise_id, :status, :num_stars], order: {exercise_id: :asc, status: :desc, num_stars: :desc}, name: "solutions_ex_stat_stars"
    remove_index :solutions, name: "index_solutions_on_exercise_id_and_published_at"
  end
end
