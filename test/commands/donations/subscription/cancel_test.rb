require_relative '../test_base'

class Donations::Subscription::CancelTest < Donations::TestBase
  test "cancels for subscription" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, user:, stripe_id: subscription_id

    Stripe::Subscription.expects(:delete).with(subscription_id)

    Donations::Subscription::Cancel.(subscription)
    refute subscription.active?
    refute user.active_donation_subscription?
  end

  test "blows up if subscription can't be deleted" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, user:, stripe_id: subscription_id

    subscription_data = mock_stripe_subscription(subscription_id, 1000, status: 'active')
    Stripe::Subscription.expects(:delete).with(subscription_id).raises(Stripe::InvalidRequestError.new(nil, nil))
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    assert_raises do
      Donations::Subscription::Cancel.(subscription)
    end
  end

  test "doesn't blow up if subscription is already cancelled" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, user:, stripe_id: subscription_id

    subscription_data = mock_stripe_subscription(subscription_id, 1000, status: 'canceled')
    Stripe::Subscription.expects(:delete).with(subscription_id).raises(Stripe::InvalidRequestError.new(nil, nil))
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    Donations::Subscription::Cancel.(subscription)
    refute subscription.active?
    refute user.active_donation_subscription?
  end
end
