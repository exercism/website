# This responds to a Paypal 'BILLING.SUBSCRIPTION.UPDATED' webhook event
class Donations::Paypal::Subscription::HandleUpdated
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
