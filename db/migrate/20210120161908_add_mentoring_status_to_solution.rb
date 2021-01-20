class AddMentoringStatusToSolution < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :mentoring_status, :tinyint, null: false, default: 0
  end
end
