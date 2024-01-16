require_relative '../../test_base'

class Payments::Stripe::Subscription::UpdateAmountTest < Payments::TestBase
  test "updates amount in stripe" do
    subscription_id = SecureRandom.uuid
    amount_in_cents = 500
    user = create :user
    subscription = create :payments_subscription, user:, external_id: subscription_id

    subscription_data = mock_stripe_subscription(subscription_id, 1000)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    Stripe::Subscription.expects(:update).with(
      subscription.external_id,
      items: [{
        id: subscription_data.items.data[0].id,
        price_data: {
          unit_amount: amount_in_cents,
          currency: 'usd',
          product: Exercism.secrets.stripe_recurring_product_id,
          recurring: {
            interval: 'month'
          }
        }
      }]
    )

    Payments::Stripe::Subscription::UpdateAmount.(subscription, amount_in_cents)
  end

  test "updates subscription amount" do
    subscription_id = SecureRandom.uuid
    amount_in_cents = 500
    user = create :user
    subscription = create :payments_subscription, user:, external_id: subscription_id

    subscription_data = mock_stripe_subscription(subscription_id, 1000)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)
    Stripe::Subscription.stubs(:update)

    Payments::Stripe::Subscription::UpdateAmount.(subscription, amount_in_cents)

    assert_equal amount_in_cents, subscription.amount_in_cents
  end
end
