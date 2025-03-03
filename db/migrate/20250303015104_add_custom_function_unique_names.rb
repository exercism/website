class AddCustomFunctionUniqueNames < ActiveRecord::Migration[7.0]
  def change
    add_index :bootcamp_custom_functions, [:user_id, :name], unique: true
  end
end
