# This responds to a Paypal 'BILLING.SUBSCRIPTION.CREATED' webhook event
class Donations::Paypal::Subscription::HandleCreated
  include Mandate

  initialize_with :resource

  def call; end
end
