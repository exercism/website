# This responds to a Paypal 'BILLING.SUBSCRIPTION.PAYMENT.FAILED' webhook event
class Donations::Paypal::Subscription::HandlePaymentFailed
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
