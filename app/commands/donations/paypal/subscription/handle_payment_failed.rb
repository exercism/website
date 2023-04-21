# This responds to a Paypal 'BILLING.SUBSCRIPTION.PAYMENT.FAILED' webhook event
class Donations::Paypal::Subscription::HandlePaymentFailed
  include Mandate

  initialize_with :resource

  def call
    subscription = Donations::Subscription.find_by(external_id: resource[:id], provider: :paypal)
    return unless subscription

    Donations::Subscription::Overdue.(subscription)
  end
end
