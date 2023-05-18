require_relative '../../test_base'

class Payments::Paypal::Subscription::HandleRecurringPaymentSkippedTest < Payments::TestBase
  test "ignores unknown subscription" do
    payload = { "recurring_payment_id" => SecureRandom.uuid }

    Payments::Paypal::Subscription::HandleRecurringPaymentSkipped.(payload)

    refute Payments::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :payments_subscription, :paypal, :active
    payload = { "recurring_payment_id" => subscription.external_id }

    refute subscription.overdue?

    Payments::Paypal::Subscription::HandleRecurringPaymentSkipped.(payload)

    assert subscription.reload.overdue?
  end
end
