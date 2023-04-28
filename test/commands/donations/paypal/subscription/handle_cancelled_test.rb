require_relative '../../test_base'

class Donations::Paypal::Subscription::HandleCancelledTest < Donations::TestBase
  test "ignores unknown subscription" do
    resource = { id: SecureRandom.uuid }

    Donations::Paypal::Subscription::HandleCancelled.(resource)

    refute Donations::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :donations_subscription, provider: :paypal, status: :active
    resource = { id: subscription.external_id }

    refute subscription.canceled?

    Donations::Paypal::Subscription::HandleCancelled.(resource)

    assert subscription.reload.canceled?
  end
end
