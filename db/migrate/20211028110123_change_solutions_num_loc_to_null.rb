class ChangeSolutionsNumLocToNull < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :num_loc, :integer, null: true
  end
end
