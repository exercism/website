require_relative '../../test_base'

class Payments::Paypal::Subscription::CreateTest < Payments::TestBase
  test "creates donation subscription correctly" do
    user = create :user
    node_id = SecureRandom.uuid
    amount = 15
    amount_in_cents = 1500

    Payments::Paypal::Subscription::Create.(user, node_id, amount, :donation, :year)

    assert_equal 1, Payments::Subscription.count

    subscription =  Payments::Subscription.last
    assert_equal node_id, subscription.external_id
    assert_equal amount_in_cents, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert_equal :paypal, subscription.provider
    assert_equal :year, subscription.interval
  end

  test "creates premium subscription correctly" do
    user = create :user
    node_id = SecureRandom.uuid
    amount = 15
    amount_in_cents = 1500

    Payments::Paypal::Subscription::Create.(user, node_id, amount, :premium, :month)

    assert_equal 1, Payments::Subscription.count

    subscription =  Payments::Subscription.last
    assert_equal node_id, subscription.external_id
    assert_equal amount_in_cents, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert_equal :paypal, subscription.provider
    assert_equal :month, subscription.interval
  end

  test "idempotent" do
    user = create :user
    node_id = SecureRandom.uuid
    amount = 15

    sub_1 = Payments::Paypal::Subscription::Create.(user, node_id, amount, :donation, :month)
    sub_2 = Payments::Paypal::Subscription::Create.(user, node_id, amount, :donation, :month)

    assert_equal 1, Payments::Subscription.count
    assert_equal sub_1, sub_2
  end

  test "triggers insiders_status update" do
    user = create :user
    node_id = SecureRandom.uuid
    amount = 15
    User::InsidersStatus::UpdateForPayment.expects(:call).with(user).at_least_once

    Payments::Paypal::Subscription::Create.(user, node_id, amount, :donation, :month)
  end
end
