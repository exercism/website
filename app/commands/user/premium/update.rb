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
    return nil if next_payment_date.nil?
    return nil if next_payment_date <= Time.current

    next_payment_date + next_payment_grace_period
  end

  memoize
  def last_payment = user.payment_payments.premium.order(:id).last

  memoize
  def next_payment_date
    return nil if last_payment.nil?
    return nil if last_payment.subscription.nil?

    case last_payment.subscription.interval
    when :month
      last_payment.created_at + 1.month
    when :year
      last_payment.created_at + 1.year
    end
  end

  memoize
  def next_payment_grace_period
    case last_payment.subscription.status
    when :canceled
      0.days
    when :active
      15.days
    when :overdue
      15.days
    end
  end

  LIFETIME_PREMIUM_UNTIL = Time.utc(9999, 12, 31).freeze
end
