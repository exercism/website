require_relative '../../test_base'

class Payments::Stripe::Subscription::CancelTest < Payments::TestBase
  test "cancels for subscription" do
    subscription_id = SecureRandom.uuid
    user = create :user
    subscription = create :payments_subscription, user:, external_id: subscription_id

    Stripe::Subscription.expects(:cancel).with(subscription_id)

    Payments::Stripe::Subscription::Cancel.(subscription)
    assert_equal :canceled, subscription.status
  end

  test "blows up if subscription can't be deleted" do
    subscription_id = SecureRandom.uuid
    user = create :user
    subscription = create :payments_subscription, user:, external_id: subscription_id

    subscription_data = mock_stripe_subscription(subscription_id, 1000, status: 'active')
    Stripe::Subscription.expects(:cancel).with(subscription_id).raises(Stripe::InvalidRequestError.new(nil, nil))
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    assert_raises do
      Payments::Stripe::Subscription::Cancel.(subscription)
    end
  end

  test "doesn't blow up if subscription is already cancelled" do
    subscription_id = SecureRandom.uuid
    user = create :user
    subscription = create :payments_subscription, user:, external_id: subscription_id

    subscription_data = mock_stripe_subscription(subscription_id, 1000, status: 'canceled')
    Stripe::Subscription.expects(:cancel).with(subscription_id).raises(Stripe::InvalidRequestError.new(nil, nil))
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    Payments::Stripe::Subscription::Cancel.(subscription)
    assert_equal :canceled, subscription.status
  end

  test "triggers insiders_status update" do
    subscription_id = SecureRandom.uuid
    user = create :user
    subscription = create :payments_subscription, user:, external_id: subscription_id

    Stripe::Subscription.expects(:cancel).with(subscription_id)
    User::InsidersStatus::Update.expects(:defer).with(user).at_least_once

    Payments::Stripe::Subscription::Cancel.(subscription)
  end
end
