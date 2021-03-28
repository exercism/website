class AddCacheDataToSolutions < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :status, :tinyint, default: 0, null: false
    add_column :solutions, :last_submitted_at, :datetime, null: true
    add_column :solutions, :num_iterations, :tinyint, default: 0, null: false
  end
end
