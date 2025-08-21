class RemoveFnFieldsFromCustomFunctions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    remove_column :bootcamp_custom_functions, :name
    rename_column :bootcamp_custom_functions, :fn_name, :name
  end
end
