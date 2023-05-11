require_relative '../../test_base'

class Donations::Paypal::Subscription::HandleRecurringPaymentSkippedTest < Donations::TestBase
  test "ignores unknown subscription" do
    payload = { "recurring_payment_id" => SecureRandom.uuid }

    Donations::Paypal::Subscription::HandleRecurringPaymentSkipped.(payload)

    refute Donations::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :donations_subscription, provider: :paypal, status: :active
    payload = { "recurring_payment_id" => subscription.external_id }

    refute subscription.overdue?

    Donations::Paypal::Subscription::HandleRecurringPaymentSkipped.(payload)

    assert subscription.reload.overdue?
  end
end
