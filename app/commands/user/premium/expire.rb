class User::Premium::Expire
  include Mandate

  initialize_with :user

  def call
    user.update!(premium_until: nil)
    update_theme!
    User::Notification::CreateEmailOnly.defer(user, :expired_premium)
    User::UpdateFlair.(user)
  end

  def update_theme!
    existing_theme = user.preferences.theme
    return unless %w[dark system].include?(existing_theme)

    user.preferences.update!(theme: nil)
  end
end
