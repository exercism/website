class AddMentoringStatsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :num_solutions_mentored, :integer, limit: 3, null: false, default: 0
    add_column :users, :mentor_satisfaction_percentage, :integer, limit: 1, null: false, default: 100
  end
end
