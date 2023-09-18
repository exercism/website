require_relative '../../../test_base'

class Payments::Paypal::Subscription::IPN::HandleRecurringPaymentFailedTest < Payments::TestBase
  test "ignores unknown subscription" do
    payload = { "recurring_payment_id" => SecureRandom.uuid }

    Payments::Paypal::Subscription::IPN::HandleRecurringPaymentFailed.(payload)

    refute Payments::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :payments_subscription, :paypal, :active
    payload = { "recurring_payment_id" => subscription.external_id }

    refute subscription.overdue?

    Payments::Paypal::Subscription::IPN::HandleRecurringPaymentFailed.(payload)

    assert subscription.reload.overdue?
  end
end
