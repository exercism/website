class AddPredefinedToCustomFunctions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :bootcamp_custom_functions, :predefined, :boolean, null: false, default: false
  end
end
