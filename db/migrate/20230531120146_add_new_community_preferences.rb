class AddNewCommunityPreferences < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_communication_preferences, :email_about_premium, :boolean, null: false, default: true
    add_column :user_communication_preferences, :email_about_insiders, :boolean, null: false, default: true
  end
end
