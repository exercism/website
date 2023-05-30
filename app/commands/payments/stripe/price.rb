module Payments::Stripe::Price
  class UnknownStripeIntervalError < RuntimeError; end
  class UnknownStripePriceError < RuntimeError; end

  MONTH_AMOUNT_IN_CENTS = 999
  YEAR_AMOUNT_IN_CENTS = 9999
  LIFETIME_AMOUNT_IN_CENTS = 49_900

  def self.amount_in_cents(price_id)
    case price_id
    when Exercism.secrets.stripe_premium_monthly_price_id
      MONTH_AMOUNT_IN_CENTS
    when Exercism.secrets.stripe_premium_yearly_price_id
      YEAR_AMOUNT_IN_CENTS
    when Exercism.secrets.stripe_premium_lifetime_price_id
      LIFETIME_AMOUNT_IN_CENTS
    else
      raise Payments::Stripe::UnknownStripePriceError, "Unknown stripe price"
    end
  end

  def self.from_interval(interval)
    case interval
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
end