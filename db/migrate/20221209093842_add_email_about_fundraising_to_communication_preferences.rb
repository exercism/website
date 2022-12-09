class AddEmailAboutFundraisingToCommunicationPreferences < ActiveRecord::Migration[7.0]
  def change
    add_column :user_communication_preferences, :email_about_fundraising_campaigns, :boolean, default: true, null: false, if_not_exists: true
  end
end
