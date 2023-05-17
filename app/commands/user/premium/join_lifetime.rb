class User::Premium::JoinLifetime
  include Mandate

  initialize_with :user

  def call
    user.update!(premium_until: Time.current + 200.years)
    User::Notification::CreateEmailOnly.defer(user, :joined_lifetime_premium)
  end
end
