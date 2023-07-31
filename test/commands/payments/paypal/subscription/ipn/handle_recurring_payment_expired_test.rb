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

  test "expiring premium subscription causes user to only be premium user for remainder of interval" do
    user = create :user, premium_until: Time.current + 2.days
    subscription = create(:payments_subscription, :premium, :paypal, :active, user:)
    create(:payments_payment, :premium, :paypal, user:, subscription:)
    payload = { "recurring_payment_id" => subscription.external_id }

    assert user.reload.premium?

    perform_enqueued_jobs do
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentExpired.(payload)
    end

    assert user.reload.premium?

    travel_to Time.current + 50.days
    refute user.reload.premium?
  end
end
