class AddThemeToUsers < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_preferences, :theme, :string, null: true
  end
end
