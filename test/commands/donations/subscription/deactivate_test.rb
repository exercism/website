require_relative '../test_base'

class Donations::Subscription::DeactivateTest < Donations::TestBase
  test "cancels subscription" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, active: true, user:, stripe_id: subscription_id

    Donations::Subscription::Deactivate.(subscription)
    refute subscription.active?
    refute user.active_donation_subscription?
  end

  test "triggers insiders_status update" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :donations_subscription, active: true, user:, stripe_id: subscription_id

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Donations::Subscription::Deactivate.(subscription)
  end
end
