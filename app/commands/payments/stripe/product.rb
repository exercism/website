module Payments::Stripe::Product
  class UnknownStripeProductError < RuntimeError; end

  # TODO: use actual value (or config/secret?)
  DONATION_PRODUCT_ID = 'DONATION_PRODUCT_ID'.freeze

  # TODO: use actual value (or config/secret?)
  PREMIUM_PRODUCT_ID = 'PREMIUM_PRODUCT_ID'.freeze

  def self.from_price(price)
    case price.product
    when DONATION_PRODUCT_ID
      :donation
    when PREMIUM_PRODUCT_ID
      :premium
    else
      raise UnknownStripeProductError
    end
  end
end
