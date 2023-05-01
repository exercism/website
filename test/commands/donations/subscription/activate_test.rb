require_relative '../test_base'

class Donations::Subscription::ActivateTest < Donations::TestBase
  test "activates subscription" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: false
    subscription = create :donations_subscription, :canceled, user:, external_id: subscription_id

    Donations::Subscription::Activate.(subscription)
    assert subscription.active?
    assert user.active_donation_subscription?
  end

  test "triggers insiders_status update" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: false
    subscription = create :donations_subscription, :canceled, user:, external_id: subscription_id

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user).at_least_once

    Donations::Subscription::Activate.(subscription)
  end
end
