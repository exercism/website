class AddReceiveOnboardingEmailsToPreferences < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :user_communication_preferences, :receive_onboarding_emails, :boolean, null: false, default: true
  end
end
