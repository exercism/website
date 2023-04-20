# This responds to a Paypal 'BILLING.SUBSCRIPTION.RE-ACTIVATED' webhook event
class Donations::Paypal::Subscription::HandleReActivated
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
