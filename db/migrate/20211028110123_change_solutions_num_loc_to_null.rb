class ChangeSolutionsNumLocToNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :solutions, :num_loc, true
    change_column_default :solutions, :num_loc, nil
  end
end
