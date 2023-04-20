# This responds to a Paypal 'BILLING.SUBSCRIPTION.CREATED' webhook event
class Donations::Paypal::Subscription::HandleCreated
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
