# This responds to a Paypal 'BILLING.SUBSCRIPTION.ACTIVATED' webhook event
class Donations::Paypal::Subscription::HandleActivated
  include Mandate

  initialize_with :resource

  def call; end
end
