class ChangeSolutionsNumLocToNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :solutions, :num_loc, true
    change_column_default :solutions, :num_loc, nil
  end
end
