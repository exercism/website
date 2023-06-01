require_relative '../../test_base'

class Payments::Paypal::Subscription::HandleRecurringPaymentFailedTest < Payments::TestBase
  test "ignores unknown subscription" do
    payload = { "recurring_payment_id" => SecureRandom.uuid }

    Payments::Paypal::Subscription::HandleRecurringPaymentFailed.(payload)

    refute Payments::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :payments_subscription, :paypal, :active
    payload = { "recurring_payment_id" => subscription.external_id }

    refute subscription.overdue?

    Payments::Paypal::Subscription::HandleRecurringPaymentFailed.(payload)

    assert subscription.reload.overdue?
  end

  test "failed premium subscription payment causes user to be premium user for grace period" do
    user = create :user, premium_until: Time.current + 2.days
    subscription = create(:payments_subscription, :premium, :paypal, :active, user:)
    create(:payments_payment, :premium, :paypal, user:, subscription:)
    payload = { "recurring_payment_id" => subscription.external_id }

    assert user.reload.premium?

    perform_enqueued_jobs do
      Payments::Paypal::Subscription::HandleRecurringPaymentFailed.(payload)
    end

    assert user.reload.premium?

    travel_to Time.current + 50.days
    refute user.reload.premium?
  end
end
