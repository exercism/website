class FurtherProfileIndexes < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_index :solutions, [:exercise_id, :status, :num_stars, :updated_at], order: {exercise_id: :asc, status: :desc, num_stars: :desc, updated_at: :desc}, name: "solutions_ex_stat_stars_upat"
    remove_index :solutions, [:exercise_id, :status, :num_stars]


    add_index :solutions, [:exercise_id, :status, :published_iteration_head_tests_status, :id], name: "index_other_comm_solutions"
  end
end
