# This responds to a Paypal 'BILLING.SUBSCRIPTION.RE-ACTIVATED' webhook event
class Donations::Paypal::Subscription::HandleReActivated
  include Mandate

  initialize_with :resource

  def call; end
end
