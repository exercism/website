# This responds to a Paypal 'BILLING.SUBSCRIPTION.PAYMENT.FAILED' webhook event
class Donations::Paypal::Subscription::HandlePaymentFailed
  include Mandate

  initialize_with :resource

  def call; end
end
