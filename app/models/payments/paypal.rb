module Payments::Paypal
  class UnknownPaypalProductError < RuntimeError; end
  class UnsupportedPaypalIntervalError < RuntimeError; end
  class InvalidIPNError < RuntimeError; end
  class IPNVerificationError < RuntimeError; end
  class InvalidAPIEventError < RuntimeError; end
  class APIEventVerificationError < RuntimeError; end

  def self.product_from_name(name)
    case name
    when Exercism.secrets.paypal_donation_product_name
      :donation
    when Exercism.secrets.paypal_premium_product_name
      :premium
    when "Monthly Premium"
      :premium
    when "Yearly Premium"
      :premium
    else
      raise UnknownPaypalProductError
    end
  end

  def self.interval_from_payment_cycle(payment_cycle)
    case payment_cycle.downcase.to_sym
    when :monthly
      :month
    when :month
      :month
    when :yearly
      :year
    when :year
      :year
    else
      raise UnsupportedPaypalIntervalError
    end
  end

  def self.plan_id_from_interval(interval)
    case interval.to_sym
    when :monthly
      Exercism.secrets.paypal_premium_monthly_plan_id
    when :month
      Exercism.secrets.paypal_premium_monthly_plan_id
    when :yearly
      Exercism.secrets.paypal_premium_yearly_plan_id
    when :year
      Exercism.secrets.paypal_premium_yearly_plan_id
    else
      raise UnsupportedPaypalIntervalError
    end
  end
end
