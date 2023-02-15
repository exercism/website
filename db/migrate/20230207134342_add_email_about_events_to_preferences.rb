class AddEmailAboutEventsToPreferences < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :user_communication_preferences, :email_about_events, :boolean, null: false, default: true
      User::CommunicationPreferences.update_all("email_about_events = receive_product_updates")
    end
  end
end
