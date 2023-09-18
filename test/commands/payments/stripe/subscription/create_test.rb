require_relative '../../test_base'

class Payments::Stripe::Subscription::CreateTest < Payments::TestBase
  %i[month year].each do |interval|
    test "creates subscription with #{interval} interval correctly" do
      user = create :user
      id = SecureRandom.uuid
      amount = 1500
      data = mock_stripe_subscription(id, amount, product: Exercism.secrets.stripe_recurring_product_id, interval:)

      Payments::Stripe::Subscription::Create.(user, data)

      assert_equal 1, Payments::Subscription.count

      subscription =  Payments::Subscription.last
      assert_equal id, subscription.external_id
      assert_equal amount, subscription.amount_in_cents
      assert_equal user, subscription.user
      assert_equal :active, subscription.status
      assert_equal :stripe, subscription.provider
      assert_equal interval, subscription.interval
    end
  end

  test "idempotent" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500
    data = mock_stripe_subscription(id, amount)

    sub_1 = Payments::Stripe::Subscription::Create.(user, data)
    sub_2 = Payments::Stripe::Subscription::Create.(user, data)

    assert_equal 1, Payments::Subscription.count
    assert_equal sub_1, sub_2
  end

  test "triggers insiders_status update" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500
    data = mock_stripe_subscription(id, amount)
    User::InsidersStatus::UpdateForPayment.expects(:call).with(user).at_least_once

    Payments::Stripe::Subscription::Create.(user, data)
  end
end
