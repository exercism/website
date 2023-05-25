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
    return nil if last_payment_grace_period.nil?

    new_premium_until = last_payment.created_at + last_payment_grace_period
    return nil if new_premium_until <= Time.current

    new_premium_until
  end

  memoize
  def last_payment = user.payment_payments.premium.order(:id).last

  memoize
  def last_payment_grace_period
    return nil if last_payment.nil?
    return nil if last_payment.subscription.nil?

    return 45.days if last_payment.subscription.active?
    return 45.days if last_payment.subscription.overdue?

    30.days
  end

  LIFETIME_PREMIUM_UNTIL = Time.utc(9999, 12, 31).freeze
end
