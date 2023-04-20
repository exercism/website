# This responds to a Paypal 'BILLING.SUBSCRIPTION.CANCELLED' webhook event
class Donations::Paypal::Subscription::HandleCancelled
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
