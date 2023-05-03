require_relative '../../test_base'

class Donations::Paypal::Subscription::HandlePaymentFailedTest < Donations::TestBase
  test "ignores unknown subscription" do
    resource = { id: SecureRandom.uuid }

    Donations::Paypal::Subscription::HandlePaymentFailed.(resource)

    refute Donations::Subscription.exists?
  end

  test "changes status to overdue for known subscription" do
    subscription = create :donations_subscription, provider: :paypal
    resource = { id: subscription.external_id }

    refute subscription.overdue?

    Donations::Paypal::Subscription::HandlePaymentFailed.(resource)

    assert subscription.reload.overdue?
  end
end
