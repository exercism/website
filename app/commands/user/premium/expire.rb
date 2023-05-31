class User::Premium::Expire
  include Mandate

  initialize_with :user

  def call
    user.update!(premium_until: nil)
    User::Notification::CreateEmailOnly.defer(user, :expired_premium)
    User::UpdateFlair.(user)
  end
end
