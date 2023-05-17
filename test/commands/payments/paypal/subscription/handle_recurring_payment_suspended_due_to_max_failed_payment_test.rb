require_relative '../../test_base'

class Payments::Paypal::Subscription::HandleRecurringPaymentSuspendedDueToMaxFailedPaymentTest < Payments::TestBase
  test "ignores unknown subscription" do
    payload = { "recurring_payment_id" => SecureRandom.uuid }

    Payments::Paypal::Subscription::HandleRecurringPaymentSuspendedDueToMaxFailedPayment.(payload)

    refute Payments::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :payments_subscription, provider: :paypal, status: :active
    payload = { "recurring_payment_id" => subscription.external_id }

    refute subscription.canceled?

    Payments::Paypal::Subscription::HandleRecurringPaymentSuspendedDueToMaxFailedPayment.(payload)

    assert subscription.reload.canceled?
  end
end
