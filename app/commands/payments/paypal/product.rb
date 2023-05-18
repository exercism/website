module Payments::Paypal::Product
  class UnknownPaypalProductError < RuntimeError; end

  DONATION_PRODUCT_NAME = 'Donate+to+Exercism%21'.freeze

  # TODO: use actual value (or config/secret?)
  PREMIUM_PRODUCT_NAME = 'PREMIUM_PRODUCT_NAME'.freeze

  def self.from_name(name)
    case name
    when Payments::Paypal::Product::DONATION_PRODUCT_NAME
      :donation
    when Payments::Paypal::Product::PREMIUM_PRODUCT_NAME
      :premium
    else
      raise UnknownPaypalProductError
    end
  end
end
