class AddCodeToBootcampData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_bootcamp_data, :access_code, :string
  end
end
