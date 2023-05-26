module Payments::Paypal::Interval
  class UnsupportedPaypalIntervalError < RuntimeError; end

  def self.from_payment_cycle(payment_cycle)
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
