module Payments::Stripe::Price
  class UnknownStripeIntervalError < RuntimeError; end

  def self.amount_in_cents_from_interval(interval)
    case normalize_interval(interval)
    when :month
      999
    when :year
      9990
    end
  end

  def self.price_id_from_interval(interval)
    case normalize_interval(interval)
    when :month
      Exercism.secrets.stripe_premium_monthly_price_id
    when :year
      Exercism.secrets.stripe_premium_yearly_price_id
    when :lifetime
      Exercism.secrets.stripe_premium_lifetime_price_id
    else
      raise Payments::Stripe::UnknownStripeIntervalError, "Unknown subscription interval"
    end
  end

  def normalize_interval(interval)
    case interval
    when :monthly
      :month
    when :yearly
      :year
    else
      interval
    end
  end
end
