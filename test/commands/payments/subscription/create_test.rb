require_relative '../test_base'

class Payments::Subscription::CreateTest < Payments::TestBase
  test "creates correctly" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500

    Payments::Subscription::Create.(user, :stripe, :month, external_id, amount)

    assert_equal 1, Payments::Subscription.count

    subscription =  Payments::Subscription.last
    assert_equal external_id, subscription.external_id
    assert_equal amount, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert_equal :stripe, subscription.provider
    assert_equal :month, subscription.interval
  end

  test "idempotent" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500

    sub_1 = Payments::Subscription::Create.(user, :stripe, :month, external_id, amount)
    sub_2 = Payments::Subscription::Create.(user, :stripe, :month, external_id, amount)

    assert_equal 1, Payments::Subscription.count
    assert_equal sub_1, sub_2
  end

  test "updates insiders status" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500
    User::InsidersStatus::UpdateForPayment.expects(:call).with(user).once

    Payments::Subscription::Create.(user, :stripe, :month, external_id, amount)
  end
end
