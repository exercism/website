require_relative '../../test_base'

class Donations::Github::Sponsorship::HandleCreatedTest < Donations::TestBase
  test "creates subscription if not a one time payment" do
    sponsorship_node_id = SecureRandom.uuid
    is_one_time = false
    amount = 300
    user = create :user, active_donation_subscription: true

    Donations::Github::Sponsorship::HandleCreated.(user, sponsorship_node_id, is_one_time, amount)

    assert_equal 1, user.donation_subscriptions.count
    subscription = user.donation_subscriptions.last
    assert_equal :active, subscription.status
    assert_equal sponsorship_node_id, subscription.external_id
    assert_equal amount, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert_equal :github, subscription.provider
    assert user.active_donation_subscription?
  end

  test "creates payment with subscription if not a one time payment" do
    freeze_time do
      sponsorship_node_id = SecureRandom.uuid
      is_one_time = false
      amount = 300
      user = create :user, active_donation_subscription: false

      Donations::Github::Sponsorship::HandleCreated.(user, sponsorship_node_id, is_one_time, amount)

      assert user.donation_subscriptions.exists?
      assert user.active_donation_subscription?
      assert_equal 1, user.donation_payments.count
      assert_equal 1, user.donation_subscriptions.count
      payment = user.donation_payments.last
      subscription = user.donation_subscriptions.last
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

    Donations::Github::Sponsorship::HandleCreated.(user, sponsorship_node_id, is_one_time, 300)

    refute user.donation_subscriptions.exists?
    refute user.active_donation_subscription?
  end

  test "creates payment without subscription if a one time payment" do
    freeze_time do
      sponsorship_node_id = SecureRandom.uuid
      is_one_time = true
      amount = 300
      user = create :user, active_donation_subscription: false

      Donations::Github::Sponsorship::HandleCreated.(user, sponsorship_node_id, is_one_time, amount)

      refute user.donation_subscriptions.exists?
      refute user.active_donation_subscription?
      assert_equal 1, user.donation_payments.count
      payment = user.donation_payments.last
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
