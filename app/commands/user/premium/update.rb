class User::Premium::Update
  include Mandate

  initialize_with :user

  def call
    user.update!(premium_until:)
    User::Notification::CreateEmailOnly.defer(user, :joined_lifetime_premium) if lifetime_premium?
  end

  private
  def premium_until
    return lifetime_premium_until if lifetime_premium?
    return last_payment_premium_until if last_payment_premium_until.present?

    nil
  end

  def lifetime_premium? = user.insider?
  def lifetime_premium_until = Time.utc(2099, 12, 31)

  def last_payment_premium_until
    last_payment_at = user.donation_payments.premium.pluck(:created_at).last
    return nil unless last_payment_at

    last_payment_at_with_grace_period = last_payment_at + 30.days
    return nil unless last_payment_at_with_grace_period > Time.current

    last_payment_at_with_grace_period
  end
end
