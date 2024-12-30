class AddBootcampDataColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :user_bootcamp_data, :level_idx, :integer, null: false, default: 0
  end
end