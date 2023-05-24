require_relative '../test_base'

class Payments::Subscription::CreateTest < Payments::TestBase
  test "creates correctly" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500

    Payments::Subscription::Create.(user, :stripe, :donation, external_id, amount)

    assert_equal 1, Payments::Subscription.count

    subscription =  Payments::Subscription.last
    assert_equal external_id, subscription.external_id
    assert_equal amount, subscription.amount_in_cents
    assert_equal user, subscription.user
    assert_equal :active, subscription.status
    assert_equal :stripe, subscription.provider
    assert_equal :donation, subscription.product
    assert user.active_donation_subscription?
  end

  test "idempotent" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500

    sub_1 = Payments::Subscription::Create.(user, :stripe, :donation, external_id, amount)
    sub_2 = Payments::Subscription::Create.(user, :stripe, :donation, external_id, amount)

    assert_equal 1, Payments::Subscription.count
    assert_equal sub_1, sub_2
  end

  test "updates insiders status when product is donation" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500
    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).once

    Payments::Subscription::Create.(user, :stripe, :donation, external_id, amount)
  end

  test "does not update insiders status when product is premium" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500
    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).never

    Payments::Subscription::Create.(user, :stripe, :premium, external_id, amount)
  end

  test "updates premium status when product is premium" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500
    User::Premium::Update.expects(:call).with(user).once

    Payments::Subscription::Create.(user, :stripe, :premium, external_id, amount)
  end

  test "does not update premium status when product is donation" do
    user = create :user
    external_id = SecureRandom.uuid
    amount = 1500
    User::Premium::Update.expects(:call).with(user).never

    Payments::Subscription::Create.(user, :stripe, :donation, external_id, amount)
  end
end
