require_relative '../test_base'

class Donations::Subscription::CreateTest < Donations::TestBase
  test "creates correctly" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500

    Donations::Subscription::Create.(user, :stripe, external_id, amount)

    assert_equal 1, Donations::Subscription.count

    subscription =  Donations::Subscription.last
    assert_equal external_id, subscription.external_id
    assert_equal amount, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert_equal :stripe, subscription.provider
    assert user.active_donation_subscription?
  end

  test "idempotent" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500

    sub_1 = Donations::Subscription::Create.(user, :stripe, external_id, amount)
    sub_2 = Donations::Subscription::Create.(user, :stripe, external_id, amount)

    assert_equal 1, Donations::Subscription.count
    assert_equal sub_1, sub_2
  end

  test "triggers insiders_status update" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500
    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Donations::Subscription::Create.(user, :stripe, external_id, amount)
  end
end
