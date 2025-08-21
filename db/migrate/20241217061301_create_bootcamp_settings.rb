class CreateBootcampSettings < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_settings do |t|
      t.timestamps
      t.integer :level_idx, null: false, default: 1
    end
  end
end
