# This responds to a Paypal 'BILLING.SUBSCRIPTION.ACTIVATED' webhook event
class Donations::Paypal::Subscription::HandleActivated
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
