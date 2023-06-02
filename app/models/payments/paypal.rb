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
    return :month if %w[Monthly Month].include?(payment_cycle)
    return :year if %w[Yearly Year].include?(payment_cycle)

    raise UnsupportedPaypalIntervalError
  end

  def self.plan_id_from_interval(interval)
    case interval
    when :monthly
      # TODO: Exercism.secrets.paypal_premium_monthly_plan_id
      'P-0TT41792VT226690TMR43JAQ'
    when :yearly
      # TODO: Exercism.secrets.paypal_premium_yearly_plan_id
      'P-7TW18726BH9867209MR43JIA'
    else
      raise UnsupportedPaypalIntervalError
    end
  end

  def self.amount_in_dollars_from_interval(interval)
    case interval
    when :monthly
      Premium::MONTH_AMOUNT_IN_CENTS / 100.0
    when :yearly
      Premium::YEAR_AMOUNT_IN_CENTS / 100.0
    when :lifetime
      Premium::LIFETIME_AMOUNT_IN_CENTS / 100.0
    end
  end
end
