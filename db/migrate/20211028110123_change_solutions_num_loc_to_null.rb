class ChangeSolutionsNumLocToNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :solutions, :num_loc, true
  end
end
