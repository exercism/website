class AddLocToIterations < ActiveRecord::Migration[6.1]
  def change
    add_column :iterations, :num_loc, :integer, null: true
  end
end
