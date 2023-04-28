require_relative '../../test_base'

class Donations::Paypal::Subscription::HandleActivatedTest < Donations::TestBase
  test "ignores unknown subscription" do
    resource = { id: SecureRandom.uuid }

    Donations::Paypal::Subscription::HandleActivated.(resource)

    refute Donations::Subscription.exists?
  end

  test "changes status to active for known subscription" do
    subscription = create :donations_subscription, provider: :paypal
    resource = { id: subscription.external_id }

    refute subscription.active?

    Donations::Paypal::Subscription::HandleActivated.(resource)

    assert subscription.reload.active?
  end
end
