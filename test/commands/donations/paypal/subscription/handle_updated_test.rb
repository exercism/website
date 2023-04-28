require_relative '../../test_base'

class Donations::Paypal::Subscription::HandleUpdatedTest < Donations::TestBase
  test "ignores unknown subscription" do
    resource = { id: SecureRandom.uuid }

    Donations::Paypal::Subscription::HandleUpdated.(resource)

    refute Donations::Subscription.exists?
  end

  test "updates amount_in_cents for known subscription" do
    subscription = create :donations_subscription, provider: :paypal, amount_in_cents: 100
    resource = {
      id: subscription.external_id,
      plan: {
        payment_definitions: [
          amount: {
            value: "5.5"
          }
        ]
      }
    }

    Donations::Paypal::Subscription::HandleUpdated.(resource)

    assert_equal 550, subscription.reload.amount_in_cents
  end
end
