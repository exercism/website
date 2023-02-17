class AddEmailOnOnboardingToPreferences < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :user_communication_preferences, :email_on_onboarding, :boolean, null: false, default: true
    end
  end
end
