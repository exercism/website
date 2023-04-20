# This responds to a Paypal 'BILLING.SUBSCRIPTION.EXPIRED' webhook event
class Donations::Paypal::Subscription::HandleExpired
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
