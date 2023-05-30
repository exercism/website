class User::Premium::Update
  include Mandate

  initialize_with :user

  def call
    return if user.premium_until == premium_until

    if expire?
      User::Premium::Expire.(user)
    else
      User::Premium::Join.(user, premium_until)
    end
  end

  private
  def premium_until
    return LIFETIME_PREMIUM_UNTIL if lifetime_premium?
    return last_payment_premium_until if last_payment_premium_until.present?

    nil
  end

  def lifetime_premium? = user.insider?
  def expire? = premium_until.nil?

  memoize
  def last_payment_premium_until
    return nil if last_payment.nil?
    return nil if last_payment.subscription.nil?
    return nil if last_payment.subscription.canceled?

    next_payment_date = last_payment.created_at + last_payment.subscription.time_interval + last_payment.subscription.grace_period
    return nil if next_payment_date <= Time.current

    next_payment_date
  end

  memoize
  def last_payment = user.payments.premium.order(:id).last

  LIFETIME_PREMIUM_UNTIL = Time.utc(9999, 12, 31).freeze
end
