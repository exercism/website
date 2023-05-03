# This responds to a Paypal 'BILLING.SUBSCRIPTION.ACTIVATED' and
# 'BILLING.SUBSCRIPTION.RE-ACTIVATED' webhook events
class Donations::Paypal::Subscription::HandleActivated
  include Mandate

  initialize_with :resource

  def call
    subscription = Donations::Subscription.find_by(external_id: resource[:id], provider: :paypal)
    return unless subscription

    Donations::Subscription::Activate.(subscription)
  end
end
