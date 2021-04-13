class AddIterationStatusToSolutions < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :iteration_status, :string, null: true
  end
end
