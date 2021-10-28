class ChangeSolutionsNumLocToNull < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :num_loc, :integer, null: true

    Solution.where(num_loc: 0).update(num_loc: nil)
  end
end
