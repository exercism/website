class AddBootcampDataColumns < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_bootcamp_data, :level_idx, :integer, null: false, default: 0
  end
end