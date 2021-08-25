class AddPublicUuidToSolutions < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :public_uuid, :string
    Solution.update_all('public_uuid = UUID()')
    change_column_null :solutions, :public_uuid, false
  end
end
