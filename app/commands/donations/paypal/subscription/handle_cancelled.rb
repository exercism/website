# This responds to a Paypal 'BILLING.SUBSCRIPTION.CANCELLED' webhook event
class Donations::Paypal::Subscription::HandleCancelled
  include Mandate

  initialize_with :resource

  def call; end
end
