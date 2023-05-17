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

  test "triggers insiders_status update" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, status: :active, user:, external_id: subscription_id

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Payments::Subscription::Cancel.(subscription)
  end
end
