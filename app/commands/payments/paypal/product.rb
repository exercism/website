module Payments::Paypal::Product
  class UnknownPaypalProductError < RuntimeError; end

  def self.from_name(name)
    case name
    when Exercism.secrets.paypal_donation_product_name
      :donation
    when Exercism.secrets.paypal_premium_product_name
      :premium
    else
      raise UnknownPaypalProductError
    end
  end
end
