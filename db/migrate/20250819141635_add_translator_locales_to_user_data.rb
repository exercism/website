class AddTranslatorLocalesToUserData < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    add_column :user_data, :translator_locales, :text, null: true
  end
end
