# This responds to a Paypal 'BILLING.SUBSCRIPTION.UPDATED' webhook event
class Donations::Paypal::Subscription::HandleUpdated
  include Mandate

  initialize_with :resource

  def call; end
end
