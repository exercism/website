# This responds to a Paypal 'PAYMENTS.PAYMENT.CREATED' webhook event
class Donations::Paypal::Payment::HandlePaymentCreated
  include Mandate

  initialize_with :resource

  def call
    payer_info = resource.dig(:payer, :payer_info)
    user = Donations::Paypal::Customer::FindOrUpdate.(payer_info[:payer_id], payer_info[:email])
    return unless user

    subscription_id = resource[:billing_agreement_id]
    amount = resource[:transactions].first.dig(:amount, :total).to_f

    subscription = Donations::Paypal::Subscription::Create.(user, subscription_id, amount) if subscription_id
    Donations::Paypal::Payment::Create.(user, resource[:id], amount, subscription:)
  end
end
