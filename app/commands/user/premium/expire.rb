class User::Premium::Expire
  include Mandate

  initialize_with :user

  def call = User::Notification::CreateEmailOnly.defer(user, :expired_premium)
end
