class AddPartToLevels < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :bootcamp_levels, :part, :integer, null: false, default: 1
  end
end
