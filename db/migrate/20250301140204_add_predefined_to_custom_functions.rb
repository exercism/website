class AddPredefinedToCustomFunctions < ActiveRecord::Migration[7.0]
  def change
    add_column :bootcamp_custom_functions, :predefined, :boolean, null: false, default: false
  end
end
