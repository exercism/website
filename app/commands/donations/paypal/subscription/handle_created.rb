# This responds to a Paypal 'BILLING.SUBSCRIPTION.CREATED' webhook event
class Donations::Paypal::Subscription::HandleCreated
  include Mandate

  initialize_with :resource

  def call
    payer_info = resource.dig(:payer, :payer_info)
    user = Donations::Paypal::Customer::FindOrUpdate.(payer_info[:payer_id], payer_info[:email])
    return unless user

    amount = resource.dig(:plan, :payment_definitions).first.dig(:amount, :value)
    Donations::Paypal::Subscription::Create.(user, resource[:id], amount)
  end
end
