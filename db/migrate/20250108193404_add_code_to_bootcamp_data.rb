class AddCodeToBootcampData < ActiveRecord::Migration[7.0]
  def change
    add_column :user_bootcamp_data, :access_code, :string
  end
end
