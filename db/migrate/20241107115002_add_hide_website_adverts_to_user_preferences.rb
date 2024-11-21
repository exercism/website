class AddHideWebsiteAdvertsToUserPreferences < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    add_column :user_preferences, :hide_website_adverts, :boolean, default: false, null: false
  end
end
