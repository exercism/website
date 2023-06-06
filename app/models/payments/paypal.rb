module Payments::Paypal
  class UnknownPaypalProductError < RuntimeError; end
  class UnsupportedPaypalIntervalError < RuntimeError; end

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
      # TODO: Exercism.secrets.paypal_premium_monthly_plan_id
      'P-0TT41792VT226690TMR43JAQ'
    when :month
      # TODO: Exercism.secrets.paypal_premium_monthly_plan_id
      'P-0TT41792VT226690TMR43JAQ'
    when :yearly
      # TODO: Exercism.secrets.paypal_premium_yearly_plan_id
      'P-7TW18726BH9867209MR43JIA'
    when :year
      # TODO: Exercism.secrets.paypal_premium_yearly_plan_id
      'P-7TW18726BH9867209MR43JIA'
    else
      raise UnsupportedPaypalIntervalError
    end
  end
end
