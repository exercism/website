class AddLocaleToUserData < ActiveRecord::Migration[7.1]
  def change
    add_column :user_data, :locale, :string, null: true
  end
end