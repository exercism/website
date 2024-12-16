class AddUtmToBootcampData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_bootcamp_data, :utm, :text, null: true
  end
end
