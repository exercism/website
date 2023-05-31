module Payments::Paypal
  class UnknownPaypalProductError < RuntimeError; end
  class UnsupportedPaypalIntervalError < RuntimeError; end

  def self.product_from_name(name)
    case name
    when Exercism.secrets.paypal_donation_product_name
      :donation
    when Exercism.secrets.paypal_premium_product_name
      :premium
    when "Monthly+Premium"
      :premium
    when "Yearly+Premium"
      :premium
    else
      raise UnknownPaypalProductError
    end
  end

  def self.interval_from_payment_cycle(payment_cycle)
    case payment_cycle
    when 'Monthly'
      :month
    when 'Yearly'
      :year
    else
      raise UnsupportedPaypalIntervalError
    end
  end
end
