# This responds to Paypal 'BILLING.SUBSCRIPTION.CANCELLED' and
# 'BILLING.SUBSCRIPTION.EXPIRED' webhook events
class Donations::Paypal::Subscription::HandleCancelled
  include Mandate

  initialize_with :resource

  def call
    subscription = Donations::Subscription.find_by(external_id: resource[:id], provider: :paypal)
    return unless subscription

    Donations::Subscription::Cancel.(subscription)
  end
end
