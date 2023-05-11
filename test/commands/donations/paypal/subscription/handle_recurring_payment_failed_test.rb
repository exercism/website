require_relative '../../test_base'

class Donations::Paypal::Subscription::HandleRecurringPaymentFailedTest < Donations::TestBase
  test "ignores unknown subscription" do
    payload = { "recurring_payment_id" => SecureRandom.uuid }

    Donations::Paypal::Subscription::HandleRecurringPaymentFailed.(payload)

    refute Donations::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :donations_subscription, provider: :paypal, status: :active
    payload = { "recurring_payment_id" => subscription.external_id }

    refute subscription.overdue?

    Donations::Paypal::Subscription::HandleRecurringPaymentFailed.(payload)

    assert subscription.reload.overdue?
  end
end
