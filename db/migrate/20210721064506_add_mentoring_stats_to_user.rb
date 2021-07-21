class AddMentoringStatsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :num_solutions_mentored, :integer, limit: 3, null: false, default: 0
    add_column :users, :satisfaction_rating, :integer, limit: 1, null: false, default: 100
  end
end
