class User::Premium::Join
  include Mandate

  initialize_with :user, :premium_until

  def call
    user.update!(premium_until:)
    User::Notification::CreateEmailOnly.defer(user, :joined_premium) if FeatureFlag::PREMIUM
  end
end
