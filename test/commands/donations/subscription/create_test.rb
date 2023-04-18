require_relative '../test_base'

class Donations::Subscription::CreateTest < Donations::TestBase
  test "creates correctly" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500
    data = mock_stripe_subscription(id, amount)

    Donations::Subscription::Create.(user, :stripe, data)

    assert_equal 1, Donations::Subscription.count

    subscription =  Donations::Subscription.last
    assert_equal id, subscription.external_id
    assert_equal amount, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert user.active_donation_subscription?
  end

  test "idempotent" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500
    data = mock_stripe_subscription(id, amount)

    sub_1 = Donations::Subscription::Create.(user, :stripe, data)
    sub_2 = Donations::Subscription::Create.(user, :stripe, data)

    assert_equal 1, Donations::Subscription.count
    assert_equal sub_1, sub_2
  end

  test "triggers insiders_status update" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500
    data = mock_stripe_subscription(id, amount)
    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Donations::Subscription::Create.(user, :stripe, data)
  end
end
