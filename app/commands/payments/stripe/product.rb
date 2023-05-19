module Payments::Stripe::Product
  class UnknownStripeProductError < RuntimeError; end

  def self.from_product_id(product_id)
    case product_id
    when Exercism.secrets.stripe_recurring_product_id
      :donation
    when Exercism.secrets.stripe_premium_product_id
      :premium
    else
      raise UnknownStripeProductError
    end
  end
end
