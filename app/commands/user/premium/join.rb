class User::Premium::Join
  include Mandate

  initialize_with :user, :premium_until

  def call
    user.update!(premium_until:)
    update_theme!
    User::Notification::CreateEmailOnly.defer(user, :joined_premium) if FeatureFlag::PREMIUM
  end

  def update_theme!
    existing_theme = user.preferences.theme
    return unless existing_theme.nil? || existing_theme == 'light'

    user.preferences.update!(theme: :dark)
  end
end
