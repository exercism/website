module Payments::Stripe
  class UnknownStripeProductError < RuntimeError; end
  class UnknownStripeIntervalError < RuntimeError; end
  class UnknownStripePriceError < RuntimeError; end

  def self.product_from_id(product_id)
    case product_id
    when Exercism.secrets.stripe_recurring_product_id
      :donation
    when Exercism.secrets.stripe_premium_product_id
      :premium
    else
      raise UnknownStripeProductError
    end
  end

  def self.amount_in_cents_from_price_id(price_id)
    case price_id
    when Exercism.secrets.stripe_premium_monthly_price_id
      Premium::MONTH_AMOUNT_IN_CENTS
    when Exercism.secrets.stripe_premium_yearly_price_id
      Premium::YEAR_AMOUNT_IN_CENTS
    when Exercism.secrets.stripe_premium_lifetime_price_id
      Premium::LIFETIME_AMOUNT_IN_CENTS
    else
      raise Payments::Stripe::UnknownStripePriceError, "Unknown stripe price"
    end
  end

  def self.price_id_from_interval(interval)
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
