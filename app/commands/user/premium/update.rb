class User::Premium::Update
  include Mandate

  initialize_with :user, context: nil

  def call
    return if user.premium_until == premium_until

    user.update!(premium_until:)
    User::Notification::CreateEmailOnly.defer(user, :joined_lifetime_premium) if lifetime_premium?
  end

  private
  def premium_until
    return LIFETIME_PREMIUM_UNTIL if lifetime_premium?
    return last_payment_premium_until if last_payment_premium_until.present?

    nil
  end

  def lifetime_premium? = user.insider?

  def last_payment_premium_until
    last_payment_at = user.payment_payments.premium.order(:id).pluck(:created_at).last
    return nil unless last_payment_at

    last_payment_at_with_grace_period = last_payment_at + LAST_PAYMENT_GRACE_PERIOD
    return nil unless last_payment_at_with_grace_period > Time.current

    last_payment_at_with_grace_period
  end

  LIFETIME_PREMIUM_UNTIL = Time.utc(2099, 12, 31).freeze
  LAST_PAYMENT_GRACE_PERIOD = 45.days.freeze
end
