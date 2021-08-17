class AddUuidToSolutionComments < ActiveRecord::Migration[6.1]
  def change
    add_column :solution_comments, :uuid, :string, null: true
    Solution::Comment.update_all('`uuid` = UUID()')
    change_column_null :solution_comments, :uuid, false
  end
end
