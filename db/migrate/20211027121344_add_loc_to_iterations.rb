class AddLocToIterations < ActiveRecord::Migration[7.0]
  def change
    add_column :iterations, :num_loc, :integer, null: true
  end
end
