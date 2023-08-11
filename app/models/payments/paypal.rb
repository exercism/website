module Payments::Paypal
  class UnknownPaypalProductError < RuntimeError; end
  class UnsupportedPaypalIntervalError < RuntimeError; end
  class InvalidIPNError < RuntimeError; end
  class IPNVerificationError < RuntimeError; end
  class InvalidAPIEventError < RuntimeError; end
  class APIEventVerificationError < RuntimeError; end

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
end
