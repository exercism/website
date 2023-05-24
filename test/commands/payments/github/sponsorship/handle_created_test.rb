require_relative '../../test_base'

class Payments::Github::Sponsorship::HandleCreatedTest < Payments::TestBase
  test "creates subscription if not a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    amount = 300
    user = create :user, active_donation_subscription: true

    Payments::Github::Sponsorship::HandleCreated.(user, sponsorship_node_id, is_one_time, amount)

    assert_equal 1, user.payment_subscriptions.count
    subscription = user.payment_subscriptions.last
    assert_equal :active, subscription.status
    assert_equal sponsorship_node_id, subscription.external_id
    assert_equal amount, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert_equal :github, subscription.provider
    assert_equal :month, subscription.interval
    assert user.active_donation_subscription?
  end

  test "creates payment with subscription if not a one time payment" do
    freeze_time do
      sponsorship_node_id = SecureRandom.uuid
      is_one_time = false
      amount = 300
      user = create :user, active_donation_subscription: false

      Payments::Github::Sponsorship::HandleCreated.(user, sponsorship_node_id, is_one_time, amount)

      assert user.payment_subscriptions.exists?
      assert user.active_donation_subscription?
      assert_equal 1, user.payment_payments.count
      assert_equal 1, user.payment_subscriptions.count
      payment = user.payment_payments.last
      subscription = user.payment_subscriptions.last
      assert_equal sponsorship_node_id, payment.external_id
      assert_equal amount, payment.amount_in_cents
      assert_nil payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :github, payment.provider
      assert_equal subscription, payment.subscription
      assert_equal amount, user.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
      assert user.donated?
    end
  end

  test "does not create a subscription if a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = true
    user = create :user, active_donation_subscription: false

    Payments::Github::Sponsorship::HandleCreated.(user, sponsorship_node_id, is_one_time, 300)

    refute user.payment_subscriptions.exists?
    refute user.active_donation_subscription?
  end

  test "creates payment without subscription if a one time payment" do
    freeze_time do
      sponsorship_node_id = SecureRandom.uuid
      is_one_time = true
      amount = 300
      user = create :user, active_donation_subscription: false

      Payments::Github::Sponsorship::HandleCreated.(user, sponsorship_node_id, is_one_time, amount)

      refute user.payment_subscriptions.exists?
      refute user.active_donation_subscription?
      assert_equal 1, user.payment_payments.count
      payment = user.payment_payments.last
      assert_equal sponsorship_node_id, payment.external_id
      assert_equal amount, payment.amount_in_cents
      assert_nil payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :github, payment.provider
      assert_nil payment.subscription
      assert_equal amount, user.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
      assert user.donated?
    end
  end
end
