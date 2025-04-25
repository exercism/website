class AddPart2FieldsToBootcampData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    rename_column :user_bootcamp_data, :level_idx, :part_1_level_idx
    add_column :user_bootcamp_data, :part_2_level_idx, :integer, null: false, default: 0

    add_column :user_bootcamp_data, :enrolled_on_part_1, :boolean, null: false, default: false
    add_column :user_bootcamp_data, :enrolled_on_part_2, :boolean, null: false, default: false

    add_column :user_bootcamp_data, :active_part, :integer, null: false, default: 1
  end
end
