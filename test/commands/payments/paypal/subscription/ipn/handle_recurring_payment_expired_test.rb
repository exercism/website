require_relative '../../../test_base'

class Payments::Paypal::Subscription::IPN::HandleRecurringPaymentExpiredTest < Payments::TestBase
  test "ignores unknown subscription" do
    payload = { "recurring_payment_id" => SecureRandom.uuid }

    Payments::Paypal::Subscription::IPN::HandleRecurringPaymentExpired.(payload)

    refute Payments::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :payments_subscription, :paypal, :active
    payload = { "recurring_payment_id" => subscription.external_id }

    refute subscription.canceled?

    Payments::Paypal::Subscription::IPN::HandleRecurringPaymentExpired.(payload)

    assert subscription.reload.canceled?
  end
end
