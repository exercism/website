require_relative '../../test_base'

class Payments::Github::Subscription::CreateTest < Payments::TestBase
  test "creates correctly" do
    user = create :user
    node_id = SecureRandom.uuid
    amount = 1500

    Payments::Github::Subscription::Create.(user, node_id, amount)

    assert_equal 1, Payments::Subscription.count

    subscription =  Payments::Subscription.last
    assert_equal node_id, subscription.external_id
    assert_equal amount, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert_equal :github, subscription.provider
    assert_equal :month, subscription.interval
  end

  test "idempotent" do
    user = create :user
    node_id = SecureRandom.uuid
    amount = 1500

    sub_1 = Payments::Github::Subscription::Create.(user, node_id, amount)
    sub_2 = Payments::Github::Subscription::Create.(user, node_id, amount)

    assert_equal 1, Payments::Subscription.count
    assert_equal sub_1, sub_2
  end

  test "triggers insiders_status update" do
    user = create :user
    node_id = SecureRandom.uuid
    amount = 1500
    User::InsidersStatus::UpdateForPayment.expects(:call).with(user).at_least_once

    Payments::Github::Subscription::Create.(user, node_id, amount)
  end
end
