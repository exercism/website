require_relative '../test_base'

class Payments::Subscription::CancelTest < Payments::TestBase
  test "cancels subscription" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, status: :active, user:, external_id: subscription_id

    Payments::Subscription::Cancel.(subscription)
    assert subscription.canceled?
    refute user.active_donation_subscription?
  end

  test "updates insiders status when product is donation" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, status: :active, product: :donation, user:, external_id: subscription_id

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).once

    Payments::Subscription::Cancel.(subscription)
  end

  test "does not update insiders status when product is premium" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, status: :active, product: :premium, user:, external_id: subscription_id

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).never

    Payments::Subscription::Cancel.(subscription)
  end

  test "updates premium status when product is premium" do
    user = create :user
    subscription = create(:payments_subscription, product: :premium, user:)

    User::Premium::Update.expects(:call).with(user).once

    Payments::Subscription::Cancel.(subscription)
  end

  test "does not update premium status when product is donation" do
    user = create :user
    subscription = create(:payments_subscription, product: :donation, user:)

    User::Premium::Update.expects(:call).with(user).never

    Payments::Subscription::Cancel.(subscription)
  end
end
