# This responds to a Paypal 'BILLING.SUBSCRIPTION.EXPIRED' webhook event
class Donations::Paypal::Subscription::HandleExpired
  include Mandate

  initialize_with :resource

  def call; end
end
