# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_profile_created'
class Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreated
  include Mandate

  initialize_with :resource

  def call
    payer_info = resource.dig(:payer, :payer_info)
    user = Donations::Paypal::Customer::FindOrUpdate.(payer_info[:payer_id], payer_info[:email])
    return unless user

    amount = resource.dig(:plan, :payment_definitions).first.dig(:amount, :value).to_f
    Donations::Paypal::Subscription::Create.(user, resource[:id], amount)
  end
end
