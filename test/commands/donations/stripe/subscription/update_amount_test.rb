require_relative '../../test_base'

class Donations::Stripe::Subscription::UpdateAmountTest < Donations::TestBase
  test "update subscription" do
    subscription_id = SecureRandom.uuid
    item_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, user:, external_id: subscription_id, amount_in_cents: 500
    new_amount_in_cents = 1200

    subscription_data = mock_stripe_subscription(subscription_id, 500, item_id:)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)
    Stripe::Subscription.expects(:update).with(
      subscription_id,
      items: [{
        id: item_id,
        price_data: {
          unit_amount: new_amount_in_cents,
          currency: 'usd',
          product: Exercism.secrets.stripe_recurring_product_id,
          recurring: {
            interval: 'month'
          }
        }
      }],
      proration_behavior: 'none'
    )

    Donations::Stripe::Subscription::UpdateAmount.(subscription, new_amount_in_cents)
    assert_equal new_amount_in_cents, subscription.amount_in_cents
  end
end
