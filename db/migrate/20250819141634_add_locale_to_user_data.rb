class AddLocaleToUserData < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    add_column :user_data, :locale, :string, if_not_exists: true
  end
end
